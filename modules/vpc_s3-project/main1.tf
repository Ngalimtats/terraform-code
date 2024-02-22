resource "aws_vpc" "prod" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "app-subnet" {
  vpc_id            = aws_vpc.prod.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "application"
  }
}


//Create an internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod.id

  tags = {
    Name = "gw"
  }
}

#create a Route Table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prod"

  }
}


# resource "aws_instance" "my-first-server" {
#   ami               = "ami-053b0d53c279acc90"
#   instance_type     = "t2.micro"
#   subnet_id         = aws_subnet.app-subnet.id
#   availability_zone = "us-east-1a"
#   vpc_security_group_ids   = [aws_security_group.server-sg.id]


# user_data = <<-EOF
# #!/bin/sh
# sudo apt update -y
# sudo apt install apache2 -y
# sudo systemctl start apache2
# sudo -i
# echo 'wirfon first server' > /var/www/html/index.html
# EOF

#   tags = {
#     Name = "Ubuntu"

#   }

# }
//routetable association

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.app-subnet.id
  route_table_id = aws_route_table.prod-route-table.id
}

resource "aws_instance" "my-first-server" {
  ami               = "ami-053b0d53c279acc90"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"


  user_data = <<EOF
#!/bin/bash
sudo apt-get update -y
sudo apt-get install httpd -y
sudo systemctl start httpd
sudo -i
echo 'wirfon first server' > /var/www/html/tatiana
EOF

  tags = {
    Name = "Ubuntu"

  }

}

module "security-group" {
  source = "./modules/security-group"
  vpc_id = var.vpc_id
  aws_subnet = var.subnet_id
}

module "s3-bucket" {
  source      = "./modules/s3-buckets"
 bucket_name = "$(var.bucket_name)tatitatsbct1"
 env = "development"
}

module "s3-bucket1" {
  source      = "./modules/s3-buckets"
 bucket_name = "$(var.bucket_name)tatitatsbct2"
 env ="production"
 versioning = "Enabled"
}