variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "critical_topic_arn" {
  description = "ARN of critical alerts SNS topic"
  type        = string
}

variable "warning_topic_arn" {
  description = "ARN of warning alerts SNS topic"
  type        = string
}
