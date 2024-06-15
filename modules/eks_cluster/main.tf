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

# Data sources to get the default VPC and its subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# Filter subnets to include only those in supported availability zones
locals {
  supported_azs = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]

  supported_subnets = [
    for subnet in data.aws_subnets.default.ids : subnet
    if contains(local.supported_azs, element(split("-", subnet), 2))
  ]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"

  cluster_name    = var.cluster_name
  cluster_version = "1.24"

  vpc_id     = var.vpc_id
  subnet_ids = local.supported_subnets

  control_plane_subnet_ids = local.supported_subnets

  eks_managed_node_groups = {
    example = {
      min_size     = var.min_capacity
      max_size     = var.max_capacity
      desired_size = var.desired_capacity

      instance_types = var.instance_type
    }
  }
}