output "critical_topic_arn" {
  description = "Critical alerts SNS topic ARN"
  value       = aws_sns_topic.critical_alerts.arn
}

output "warning_topic_arn" {
  description = "Warning alerts SNS topic ARN"
  value       = aws_sns_topic.warning_alerts.arn
}

output "info_topic_arn" {
  description = "Info alerts SNS topic ARN"
  value       = aws_sns_topic.info_alerts.arn
}
