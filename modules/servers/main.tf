
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


resource "aws_instance" "server" {
  ami               = data.aws_ami.amazon_linux.id
  instance_type     = var.instance_type
  subnet_id         = var.private_subnets[0]
  availability_zone = var.aws_availability_zones[0]
  vpc_security_group_ids   =[aws_security_group.server_sg.id]
  iam_instance_profile = aws_iam_instance_profile.this.name
  #user_data = "${file("user-data.sh")}"
  user_data = <<-EOF
    #!/bin/bash

    sudo yum update -y
    sudo yum install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
  EOF


  tags = {
    Name = "${var.org_name}-server"
  }
}


resource "aws_security_group" "server_sg" {
  name        = "server_security_group"
  description = "Allows traffic from lb"
  vpc_id      = var.vpcid

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.org_name}-server-sg"
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "loadbalancer_security_group"
  description = "Allow internet traffic"
  vpc_id      = var.vpcid

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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
    Name = "${var.org_name}-lb-sg"
  }
}

#Instance profile
data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name = "janes-project-role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "this" {
  name = "janes-project-instance-profile"
  role = aws_iam_role.this.name
}



#Loadbalancer
resource "aws_lb" "this" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            =  var.public_subnets    

  enable_deletion_protection = false
  tags = {
    Name = "${var.project_name}-lb"
  }
}


resource "aws_lb_target_group" "this" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpcid
}


resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.server.id
  port             = 80
}


resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}