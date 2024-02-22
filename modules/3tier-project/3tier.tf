provider "aws" {
  region = "us-east-1"
  profile = "default"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "private_subnet" {
    count = 2
    vpc_id     = aws_vpc.main.id
    cidr_block              = element(["10.0.1.0/24", "10.0.2.0/24"], count.index)
    availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)

    tags = {
        Name = "private-subnet"
    }
}

resource "aws_subnet" "public_subnet" {
    count                   = 2
    vpc_id                  = aws_vpc.main.id
    cidr_block              = element(["10.0.3.0/24", "10.0.4.0/24"], count.index)
    availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
}


resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "gw"
    }
}


resource "aws_route_table" "main_route_table" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }
}

resource "aws_route_table_association" "rta" {
    subnet_id      = aws_subnet.private_subnet[0].id
    route_table_id = aws_route_table.main_route_table.id

}

resource "aws_route_table_association" "rtb" {
    subnet_id      = aws_subnet.public_subnet[0].id
    route_table_id = aws_route_table.main_route_table.id
}


resource "aws_security_group" "frontend_sg" {
    name        = "frontend_sg"
    description = "Allow web inbound traffic"
    vpc_id      = aws_vpc.main.id

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
}


resource "aws_security_group" "backend_sg" {
    name        = "backend_sg"
    description = "Allow web inbound traffic"
    vpc_id      = aws_vpc.main.id

    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.frontend_sg.id]
    }
}

resource "aws_instance" "frontend" {
  ami           = "ami-053b0d53c279acc90" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet[0].id
  security_groups = [aws_security_group.frontend_sg.id]

  tags = {
    Name ="frontend-server"
  }

user_data = <<-EOF
#!/bin/sh
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl start apache2
sudo -i
echo "This is my frontend server" > /var/www/html/index.html
EOF             

}

output "public_ip" {
  value = aws_instance.frontend.public_ip
  description = "The public IP of the Instance"
  
}
resource "aws_eip" "one" {
  instance = aws_instance.frontend.id
  
  depends_on = [ aws_internet_gateway.gw]
}


resource "aws_eip_association" "eip_assoc"{ 
  instance_id   = aws_instance.frontend.id
  allocation_id = aws_eip.one.id
}


resource "aws_instance" "backend" {
  ami           = "ami-053b0d53c279acc90" # Replace with your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet[0].id
  security_groups = [aws_security_group.backend_sg.id]

  tags = {
    Name = "backend-server"
  }

user_data = <<-EOF
#!/bin/sh
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl start apache2
sudo -i
echo "This is my backend server" > /var/www/html/index.html
EOF

}


resource "aws_db_subnet_group" "db_subnet" {
  name = "main"
  subnet_ids = ["${aws_subnet.private_subnet[0].id}", "${aws_subnet.private_subnet[1].id}"]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "database" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = "db_user"
  password             = "db_password"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = "${aws_db_subnet_group.db_subnet.name}"
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
}