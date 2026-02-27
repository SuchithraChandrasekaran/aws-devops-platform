output "lambda_functions" {
  description = "Lambda function ARNs"
  value = {
    auto_stop_resources   = aws_lambda_function.auto_stop_resources.arn
    auto_tag              = aws_lambda_function.auto_tag.arn
    backup_verify         = aws_lambda_function.backup_verify.arn
    security_remediation  = aws_lambda_function.security_remediation.arn
    health_check          = aws_lambda_function.health_check.arn
  }
}

output "eventbridge_rules" {
  description = "EventBridge rule ARNs"
  value = {
    auto_stop     = aws_cloudwatch_event_rule.auto_stop.arn
    health_check  = aws_cloudwatch_event_rule.health_check.arn
    backup_verify = aws_cloudwatch_event_rule.backup_verify.arn
  }
}
