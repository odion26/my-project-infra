output "ec2_project_security_group_id" {
  description = "The ID of the project security group"
  value       = aws_security_group.project-SG.id
}

output "security_group_name" {
  description = "The name of the project security group"
  value       = aws_security_group.project-SG.name
}
