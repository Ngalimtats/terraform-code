
variable "instance_type" {
    description = "aws instance type details"
}
variable "vpcid" {
    description = "ID of the VPC"
}
variable "aws_availability_zones" {
    type = list(string)
    description = "availability zones hosting the subnets"
}
variable "public_subnets" {
    type = list(string)
    description = "List of IDs of prublic subnets"
}

variable "private_subnets" {
    type = list(string)
    description = "List of IDs of private subnets"
}

variable "org_name"{}
variable "project_name" {}