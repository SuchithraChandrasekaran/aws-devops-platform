# AWS DevOps Platform - Day 4
# Terraform Variables
# Location: infrastructure/terraform/localstack/variables.tf

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "localstack_endpoint" {
  description = "LocalStack endpoint URL"
  type        = string
  default     = "http://localhost:4566"
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "development"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "aws-devops-platform"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "aws-devops-sample-app"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "aws-devops-key"
}

variable "public_key_path" {
  description = "Path to the public SSH key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "security_group_name" {
  description = "Name of the security group"
  type        = string
  default     = "aws-devops-sg"
}

variable "docker_image" {
  description = "Docker image name"
  type        = string
  default     = "aws-devops-sample-app"
}

variable "docker_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "container_name" {
  description = "Name of the Docker container"
  type        = string
  default     = "sample-app"
}

variable "allocate_elastic_ip" {
  description = "Whether to allocate an Elastic IP"
  type        = bool
  default     = false
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Size of root EBS volume in GB"
  type        = number
  default     = 20
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default = {
    Day       = "4"
    ManagedBy = "Terraform"
  }
}
