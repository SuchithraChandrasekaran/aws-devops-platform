# AWS DevOps Platform - Day 4
# Terraform Outputs
# Location: infrastructure/terraform/localstack/outputs.tf

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}

output "instance_state" {
  description = "State of the EC2 instance"
  value       = aws_instance.app_server.instance_state
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.app_sg.id
}

output "security_group_name" {
  description = "Name of the security group"
  value       = aws_security_group.app_sg.name
}

output "key_pair_name" {
  description = "Name of the key pair"
  value       = aws_key_pair.app_key.key_name
}

output "elastic_ip" {
  description = "Elastic IP address (if allocated)"
  value       = var.allocate_elastic_ip ? aws_eip.app_eip[0].public_ip : "Not allocated"
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_instance.app_server.public_ip}:3000"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.app_server.public_ip}"
}

output "instance_tags" {
  description = "Tags applied to the instance"
  value       = aws_instance.app_server.tags
}

output "deployment_summary" {
  description = "Summary of the deployment"
  value = {
    instance_id     = aws_instance.app_server.id
    instance_type   = aws_instance.app_server.instance_type
    public_ip       = aws_instance.app_server.public_ip
    private_ip      = aws_instance.app_server.private_ip
    security_group  = aws_security_group.app_sg.id
    environment     = var.environment
    docker_image    = "${var.docker_image}:${var.docker_tag}"
  }
}
