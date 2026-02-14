variable "environment" {
  description = "Environment name"
  type        = string
}

variable "alert_email" {
  description = "Email for alert notifications"
  type        = string
  default     = "devops@example.com"
}
