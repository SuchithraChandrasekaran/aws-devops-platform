variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
  default     = "aws-devops"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "my_ip" {
  description = "Your public IP for SSH access - run: curl ifconfig.me"
  type        = string
}
