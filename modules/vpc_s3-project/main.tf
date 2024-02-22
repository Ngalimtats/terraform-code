provider "aws" {
  profile = "default"
  region  = "us-east-1"
}


resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "public-1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true #so that any instance launched in this subnet is assigned a public ip

}

resource "aws_subnet" "public-2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rtb" {
  subnet_id      = aws_subnet.public-2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg" {
  name_prefix = "sg"
  vpc_id      = aws_vpc.myvpc.id
  description = "Allow http to servers"

  ingress {
    description = "HTTP from VPC"
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

resource "aws_s3_bucket" "my-bucket" {
  bucket = var.bucket_name
}

resource "aws_instance" "webserver1" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = aws_subnet.public-1.id
  iam_instance_profile   = aws_iam_instance_profile.my_instance_profile.name_prefix
  # user_data_base64 =               base64decode(file("userdata.sh"))
  tags = {
    Name = "webserver1"
  }

  user_data = <<-EOF
#!bin/sh
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl start apache2
sudo -i
echo 'wirfon first server' > /var/www/html/index.html
sudo apt install awscli -y
EOF

}

resource "aws_instance" "webserver2" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = aws_subnet.public-2.id
  iam_instance_profile   = aws_iam_instance_profile.my_instance_profile.name
  #  user_data_base64 =               base64decode(file("userdata1.sh"))

   tags = {
    Name = "webserver2"
  }

  user_data = <<-EOF
#!bin/sh
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl start apache2
sudo -i
echo 'wirfon second server' > /var/www/html/index.html
sudo apt install awscli -y
EOF

}

#create an ALB
resource "aws_lb" "my-alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.public-1.id, aws_subnet.public-2.id]

  tags = {
    Name = "web"
  }
}

resource "aws_lb_target_group" "tg" {
  # Name = "my-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attachment1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attachment2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_lb_listener" "listiner" {
  load_balancer_arn = aws_lb.my-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}


output "load-balancer-dns" {
  value = aws_lb.my-alb.dns_name
}




resource "aws_iam_instance_profile" "my_instance_profile" {
  name = "my-instance-profile"
  role = aws_iam_role.ec2_s3_role.name
}

resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2_s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3-accesss-policy"
  description = "My policy for S3 access by my webservers"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::var.bucket_name",
          "arn:aws:s3:::var.bucket_name/*",
        ],
      },
    ],
  })
}

resource "aws_iam_policy_attachment" "policy_attachment" {
  name       = "policy-attachment"
  policy_arn = aws_iam_policy.s3_access_policy.arn
  roles      = [aws_iam_role.ec2_s3_role.name]
}