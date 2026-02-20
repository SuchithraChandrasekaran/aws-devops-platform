variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "myapp"
}

variable "log_group_arns" {
  description = "CloudWatch log group ARNs for logging permissions"
  type        = list(string)
  default     = []
}

variable "sns_topic_arns" {
  description = "SNS topic ARNs for notification permissions"
  type        = list(string)
  default     = []
}
