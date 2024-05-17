variable "region" {
  description = "The AWS region to deploy to"
  default     = "us-west-2"
}

variable "vpc_name" {
  description = "The name of the VPC"
  default     = "eks-vpc"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_id" {


}
variable "private_subnets" {
  description = "The private subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "The public subnets"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  default     = "my-eks-cluster"
}

variable "desired_capacity" {
  description = "The desired number of worker nodes"
  default     = 2
}

variable "max_capacity" {
  description = "The maximum number of worker nodes"
  default     = 3
}

variable "min_capacity" {
  description = "The minimum number of worker nodes"
  default     = 1
}

variable "instance_type" {
  description = "The instance type for the worker nodes"
  default     = "t3.medium"
}

