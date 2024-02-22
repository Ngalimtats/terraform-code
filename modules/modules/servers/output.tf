output "server_security_group_id" {
  description = "The ID of the security server group"
  value       = aws_security_group.server_sg.id
}
