terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">=4.0.0"
    }
  }
}
provider "aws" {
    region = var.region
    profile = "default"
}

module "vpc" {
    source = "../modules/network"
    vpc_cidr = var.vpc_cidr
    project_name = var.project_name
}

module "webserver1" {
  source = "../modules/servers"
  instance_type = var.instance_type
  vpcid = module.vpc.vpc_id
  aws_availability_zones = module.vpc.aws_availability_zones
  public_subnets = module.vpc.public_subnets_id
  private_subnets = module.vpc.private_subnets_id
  project_name = var.project_name
  org_name = var.org_name
}