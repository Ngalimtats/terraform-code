
variable "vpc_cidr" {
    type = string
    description = "CIDR block of VPC"
}
variable "aws_availability_zones" {
    type = list(string)
    description = "availability zones hosting the subnets"
}
# variable "ami_id" {
#     type = string
#     description = "value of the ami ID"
# }
variable "private_subnets_cidrs" {
    type = list(string)
    description = "private subnets CIDR"
}
variable "public_subnets_cidrs" {
    type = list(string)
    description = "private subnets CIDR"
}

variable "project_name" {}
variable "instance_type" {}
variable "org_name"{}
variable "region" {}
variable "vpc_name" {}


