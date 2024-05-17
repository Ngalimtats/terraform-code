terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.0.0"
    }
  }
}
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

import {
  id = i-063f165d2917318eb
  to = aws_instance.example
}

# resource "aws_instance" "example" {
#     instance_type = 
# }

