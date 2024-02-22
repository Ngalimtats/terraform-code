variable "vpc_cidr" {}
variable "project_name" {}
variable "region" {}
variable "org_name"{}

variable "instance_type" {
    description = "aws instance type details"
}
# variable "vpc_id" {
#     description = "ID of the VPC"
# }
# variable "public_subnets_id" {
#     type = list(string)
#     description = "List of IDs of prublic subnets"
# }

# variable "private_subnets_id" {
#     type = list(string)
#     description = "List of IDs of private subnets"
# }
