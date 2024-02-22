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