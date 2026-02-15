variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "aws-devops-platform"
}

variable "alert_email" {
  description = "Email address for alert notifications"
  type        = string
  default     = "suchithrac@gmail.com"
}
