output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.app_logs.name
}

output "log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = aws_cloudwatch_log_group.app_logs.arn
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.monitoring.dashboard_name
}

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
