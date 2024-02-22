variable "dev-region" {
  type        = string
  default     = "us-east-1"
  description = "Region to deployment development resources"
}

variable "prod-region" {
  type        = list(string)
  default     = ["us-east-1"]
  description = "Region to deployment Production resources"
}

variable "subnet_id" {
  type = string
  default = "us-east-1"
  description = "subnet"
}

variable "vpc_id"{
  type = string
  default = "aws_vpc"
  description = "vpc of servers"
}

variable "dev_tags" {
  type    = number
  default = 1234.45
}

variable "org_name" {
  type = string
  default = "tatitats"
}

variable "environment" {
  type = string
  default = "friday-lab"
}

variable "purpose" {
  type    = string
  default = "Cloud learning"
}