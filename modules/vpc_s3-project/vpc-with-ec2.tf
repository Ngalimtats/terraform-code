provider "aws" {
  region  = "us-east-1"
  profile = "default"
}


#resource "aws_s3_bucket" "_dev_bucket" {
#  bucket = "yvebuket2012"

# tags = {
#    Name        = "My bucket"
#   Environment = "Dev"
#  }
#}

// Create a VPC
resource "aws_vpc" "prod" {
  cidr_block = "10.0.0.0/16"


  tags = {
    Name = "production"
  }
}

//Create Subnets

resource "aws_subnet" "app-subnet" {
  vpc_id            = aws_vpc.prod.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "application"
  }
}
//resource "aws_subnet" "db-subnet" {
  //vpc_id            = aws_vpc.prod.id
  //cidr_block        = "10.0.2.0/24"
  //availability_zone = "us-east-1a"

  //tags = {
  // Name = "database"
  //}
//}

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


resource "aws_instance" "my-first-server" {
  ami               = "ami-053b0d53c279acc90"
  instance_type     = "t2.micro"
  subnet_id         = aws_subnet.app-subnet.id
  availability_zone = "us-east-1a"
  vpc_security_group_ids   = [aws_security_group.server-sg.id]


user_data = <<-EOF
#!/bin/sh
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl start apache2
sudo -i
echo 'wirfon first server' > /var/www/html/index.html
EOF

  tags = {
    Name = "Ubuntu"

  }

}
//routetable association

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.app-subnet.id
  route_table_id = aws_route_table.prod-route-table.id

}

//resource "aws_route_table_association" "b" {
//gateway_id     = aws_internet_gateway.gw.id
//route_table_id = aws_route_table.prod-route-table.id
//}

#Create Security Groups

resource "aws_security_group" "server-sg" {
  name        = "server-sg"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.prod.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "allow_web"
  }
}

output "public_ip" {
  value = aws_instance.my-first-server.public_ip
  description = "The public IP of the Instance"
  
}
#Create A network interface

//resource "aws_network_interface" "nic" {
  //subnet_id = aws_subnet.app-subnet.id
  #private_ips     = ["10.0.0.50"]
  #security_groups = [aws_security_group.web.id]

 // attachment {
   // instance     = aws_instance.my-first-server.id
    //device_index = 1
 // }
//}

//Elastic ip address

resource "aws_eip" "one" {
  instance = aws_instance.my-first-server.id
  
  depends_on = [ aws_internet_gateway.gw ]
}

//elastic ip association

resource "aws_eip_association" "eip_assoc"{ 
  instance_id   = aws_instance.my-first-server.id
  allocation_id = aws_eip.one.id
}



