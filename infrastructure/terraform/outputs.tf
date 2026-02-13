output "cloudwatch_log_group" {
  description = "CloudWatch log group for application"
  value       = module.cloudwatch.log_group_name
}

output "cloudwatch_dashboard" {
  description = "CloudWatch dashboard name"
  value       = module.cloudwatch.dashboard_name
}
