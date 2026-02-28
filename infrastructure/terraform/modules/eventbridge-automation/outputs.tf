output "lambda_functions" {
  description = "Event handler Lambda function ARNs"
  value = {
    ec2_handler         = aws_lambda_function.ec2_handler.arn
    s3_security_handler = aws_lambda_function.s3_security_handler.arn
    iam_audit_handler   = aws_lambda_function.iam_audit_handler.arn
    alarm_handler       = aws_lambda_function.alarm_handler.arn
  }
}

output "eventbridge_rules" {
  description = "EventBridge rule ARNs"
  value = {
    ec2_state_change     = aws_cloudwatch_event_rule.ec2_state_change.arn
    ec2_launch           = aws_cloudwatch_event_rule.ec2_launch.arn
    sg_change            = aws_cloudwatch_event_rule.security_group_change.arn
    s3_bucket_created    = aws_cloudwatch_event_rule.s3_bucket_created.arn
    s3_public_access     = aws_cloudwatch_event_rule.s3_public_access.arn
    iam_policy_change    = aws_cloudwatch_event_rule.iam_policy_change.arn
    root_account_usage   = aws_cloudwatch_event_rule.root_account_usage.arn
    alarm_state_change   = aws_cloudwatch_event_rule.alarm_state_change.arn
  }
}
