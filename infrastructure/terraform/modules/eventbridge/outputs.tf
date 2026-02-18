output "event_bus_arn" {
  description = "Custom event bus ARN"
  value       = aws_cloudwatch_event_bus.app_events.arn
}

output "event_bus_name" {
  description = "Custom event bus name"
  value       = aws_cloudwatch_event_bus.app_events.name
}

output "scheduled_rules" {
  description = "Scheduled rule names"
  value = {
    health_check      = aws_cloudwatch_event_rule.health_check.name
    daily_cleanup     = aws_cloudwatch_event_rule.daily_cleanup.name
    weekly_report     = aws_cloudwatch_event_rule.weekly_report.name
    metric_collection = aws_cloudwatch_event_rule.metric_collection.name
  }
}

output "pattern_rules" {
  description = "Pattern-based rule names"
  value = {
    alarm_state_change = aws_cloudwatch_event_rule.alarm_state_change.name
    ec2_state_change   = aws_cloudwatch_event_rule.ec2_state_change.name
    app_error_event    = aws_cloudwatch_event_rule.app_error_event.name
    deployment_event   = aws_cloudwatch_event_rule.deployment_event.name
  }
}
