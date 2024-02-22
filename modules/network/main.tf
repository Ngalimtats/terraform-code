
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames  = true

   tags = {
    Name = "${var.project_name}_vpc"
  }
}

# Public subnet creation
resource "aws_subnet" "public" {
  count = 2
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${var.project_name}-${count.index + 1}"
  }
}

# Private subnet creation
resource "aws_subnet" "private" {
  count = 2

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 4)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  
  tags = {
    Name = "private-subnet-${var.project_name}-${count.index + 1}"
  }
}

# Database subnet creation
resource "aws_subnet" "database" {
  count = 2

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 8)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "database-subnet-${var.project_name}-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id

    tags = {
        Name = "${var.project_name}-igw"
    }
}

#NAT gateway creation -needs eip
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = aws_subnet.public[0].id
  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = "${var.project_name}-NATgw"
  }
}

resource "aws_eip" "this" {}

#Route tables
resource "aws_route_table" "this" {
    vpc_id = aws_vpc.this.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.this.id
    }
    tags = {
    Name = "${var.project_name}-main-rt"
  }
}

resource "aws_route_table" "private-rt" {
    vpc_id = aws_vpc.this.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.this.id
    }
    tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private-rta" {
    count          = length(aws_subnet.private)
    subnet_id      = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "public-rta" {
    count          = length(aws_subnet.public)
    subnet_id      = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.this.id
}

resource "aws_route_table_association" "database-rta" {
    count          = length(aws_subnet.database)
    subnet_id      = aws_subnet.database[count.index].id
    route_table_id = aws_route_table.this.id
}