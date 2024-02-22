output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "aws_availability_zones" {
  value = data.aws_availability_zones.available.names
}
output "private_subnets_id" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnets_id" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}
output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = aws_subnet.public[*].cidr_block
}
