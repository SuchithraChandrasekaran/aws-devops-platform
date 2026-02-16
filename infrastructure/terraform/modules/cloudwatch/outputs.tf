# CloudWatch Module Outputs

# Log Groups (from Day 16 - log-groups.tf)
output "application_log_group" {
  description = "Application log group name"
  value       = aws_cloudwatch_log_group.application.name
}

output "api_log_group" {
  description = "API log group name"
  value       = aws_cloudwatch_log_group.api.name
}

output "errors_log_group" {
  description = "Errors log group name"
  value       = aws_cloudwatch_log_group.errors.name
}

output "log_streams" {
  description = "Log stream names"
  value = {
    application = aws_cloudwatch_log_stream.app_stream.name
    api         = aws_cloudwatch_log_stream.api_stream.name
    errors      = aws_cloudwatch_log_stream.error_stream.name
  }
}

# Dashboard (from Day 18 - dashboards/main-dashboard.tf)
output "dashboard_name" {
  description = "Operations dashboard name"
  value       = aws_cloudwatch_dashboard.operations.dashboard_name
}

output "dashboard_arn" {
  description = "Operations dashboard ARN"
  value       = aws_cloudwatch_dashboard.operations.dashboard_arn
}

# Alarms (from Day 17 - alarms.tf)
output "alarm_arns" {
  description = "CloudWatch alarm ARNs"
  value = {
    high_cpu    = aws_cloudwatch_metric_alarm.high_cpu.arn
    high_memory = aws_cloudwatch_metric_alarm.high_memory.arn
    high_errors = aws_cloudwatch_metric_alarm.high_errors.arn
    high_latency = aws_cloudwatch_metric_alarm.high_latency.arn
  }
}
