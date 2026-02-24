output "sg_remediation_function_arn" {
  description = "Security Group remediation Lambda ARN"
  value       = aws_lambda_function.sg_remediation.arn
}

output "iam_remediation_function_arn" {
  description = "IAM remediation Lambda ARN"
  value       = aws_lambda_function.iam_remediation.arn
}

output "s3_remediation_function_arn" {
  description = "S3 remediation Lambda ARN"
  value       = aws_lambda_function.s3_remediation.arn
}

output "eventbridge_rule_name" {
  description = "EventBridge rule name"
  value       = aws_cloudwatch_event_rule.security_findings.name
}
