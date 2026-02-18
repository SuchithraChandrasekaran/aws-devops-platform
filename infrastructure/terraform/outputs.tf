# Terraform Outputs

# CloudWatch Log Groups
output "application_log_group" {
  description = "Application log group name"
  value       = module.cloudwatch.application_log_group
}

output "api_log_group" {
  description = "API log group name"
  value       = module.cloudwatch.api_log_group
}

output "errors_log_group" {
  description = "Errors log group name"
  value       = module.cloudwatch.errors_log_group
}

# Dashboard
output "dashboard_name" {
  description = "Operations dashboard name"
  value       = module.cloudwatch.dashboard_name
}

# SNS Topics
output "critical_topic_arn" {
  description = "Critical alerts SNS topic ARN"
  value       = module.sns.critical_topic_arn
}

output "warning_topic_arn" {
  description = "Warning alerts SNS topic ARN"
  value       = module.sns.warning_topic_arn
}

# EventBridge
output "event_bus_name" {
  description = "Custom event bus name"
  value       = module.eventbridge.event_bus_name
}
