variable "environment" {
  description = "Environment name"
  type        = string
}

variable "critical_topic_arn" {
  description = "ARN of critical alerts SNS topic"
  type        = string
}

variable "warning_topic_arn" {
  description = "ARN of warning alerts SNS topic"
  type        = string
}
