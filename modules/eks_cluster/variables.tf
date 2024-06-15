variable "region" {
  description = "The AWS region to deploy to"
}
variable "cluster_name" {
  description = "The name of the EKS cluster"
}

variable "vpc_id" {
  description = "The VPC ID to deploy into"
}
variable "subnet_ids" {
  description = "The subnet IDs to deploy into"
}
variable "control_plane_subnet_ids" {
  description = "The subnet IDs to deploy control plane into"
}
variable "desired_capacity" {
  description = "The desired number of worker nodes"
}

variable "max_capacity" {
  description = "The maximum number of worker nodes"
}

variable "min_capacity" {
  description = "The minimum number of worker nodes"
}

variable "instance_type" {
  description = "The instance type for the worker nodes"
}

