# Policy ARNs
output "cloudwatch_logs_write_policy_arn" {
  description = "CloudWatch Logs write policy ARN"
  value       = aws_iam_policy.cloudwatch_logs_write.arn
}

output "cloudwatch_metrics_write_policy_arn" {
  description = "CloudWatch Metrics write policy ARN"
  value       = aws_iam_policy.cloudwatch_metrics_write.arn
}

output "sns_publish_policy_arn" {
  description = "SNS publish policy ARN"
  value       = aws_iam_policy.sns_publish.arn
}

output "eventbridge_put_events_policy_arn" {
  description = "EventBridge put events policy ARN"
  value       = aws_iam_policy.eventbridge_put_events.arn
}

output "s3_read_only_policy_arn" {
  description = "S3 read-only policy ARN"
  value       = aws_iam_policy.s3_read_only.arn
}

output "s3_write_policy_arn" {
  description = "S3 write policy ARN"
  value       = aws_iam_policy.s3_write.arn
}

# Role ARNs
output "application_service_role_arn" {
  description = "Application service role ARN"
  value       = aws_iam_role.application_service.arn
}

output "application_service_role_name" {
  description = "Application service role name"
  value       = aws_iam_role.application_service.name
}

output "worker_service_role_arn" {
  description = "Worker service role ARN"
  value       = aws_iam_role.worker_service.arn
}

output "worker_service_role_name" {
  description = "Worker service role name"
  value       = aws_iam_role.worker_service.name
}

output "monitoring_service_role_arn" {
  description = "Monitoring service role ARN"
  value       = aws_iam_role.monitoring_service.arn
}

output "monitoring_service_role_name" {
  description = "Monitoring service role name"
  value       = aws_iam_role.monitoring_service.name
}

output "admin_role_arn" {
  description = "Admin role ARN"
  value       = aws_iam_role.admin.arn
}

output "admin_role_name" {
  description = "Admin role name"
  value       = aws_iam_role.admin.name
}
