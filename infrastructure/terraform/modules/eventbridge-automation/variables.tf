variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "ec2_handler_lambda_arn" {
  description = "EC2 handler Lambda ARN"
  type        = string
  default     = ""
}

variable "auto_tag_lambda_arn" {
  description = "Auto-tag Lambda ARN"
  type        = string
  default     = ""
}

variable "security_audit_lambda_arn" {
  description = "Security audit Lambda ARN"
  type        = string
  default     = ""
}

variable "s3_security_lambda_arn" {
  description = "S3 security Lambda ARN"
  type        = string
  default     = ""
}

variable "s3_remediation_lambda_arn" {
  description = "S3 remediation Lambda ARN"
  type        = string
  default     = ""
}

variable "iam_audit_lambda_arn" {
  description = "IAM audit Lambda ARN"
  type        = string
  default     = ""
}

variable "security_alert_lambda_arn" {
  description = "Security alert Lambda ARN"
  type        = string
  default     = ""
}

variable "alarm_handler_lambda_arn" {
  description = "Alarm handler Lambda ARN"
  type        = string
  default     = ""
}
