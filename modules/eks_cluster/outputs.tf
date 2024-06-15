output "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = try(module.eks.cluster_id, "")
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = try(module.eks.endpoint, null)
}

output "cluster_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the cluster security group"
  value       = try(module.eks.aws_security_group.cluster[0].arn, null)
}

output "cluster_security_group_id" {
  description = "ID of the cluster security group"
  value       = try(module.eks.aws_security_group.cluster[0].id, null)
}

output "node_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the node shared security group"
  value       = try(module.eks.aws_security_group.node[0].arn, null)
}

output "node_security_group_id" {
  description = "ID of the node shared security group"
  value       = try(module.eks.aws_security_group.node[0].id, null)
}

# output "kubeconfig" {
#   description = "Kubeconfig file content for the EKS cluster"
#   value       = module.eks.kubeconfig
# }

output "default_vpc_id" {
  value = data.aws_vpc.default.id
}

output "default_subnet_ids" {
  value = data.aws_subnets.default.ids
}