variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "myapp"
}

variable "alert_email" {
  description = "Email address for alert notifications"
  type        = string
  default     = "devops@example.com"
}
