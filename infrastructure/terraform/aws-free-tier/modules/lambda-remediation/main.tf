variable "sns_topic_arn" {
  type = string
}

variable "role_arn" {
  description = "IAM role ARN from Day 48 eventbridge module"
  type        = string
}

resource "aws_lambda_function" "auto_tag_ec2" {
  function_name = "auto-tag-ec2"
  runtime       = "python3.12"
  handler       = "auto_tag_ec2.handler"
  role          = var.role_arn
  filename      = "${path.module}/auto_tag_ec2.zip"
  timeout       = 30
}

resource "aws_lambda_function" "s3_encryption_check" {
  function_name = "s3-encryption-check"
  runtime       = "python3.12"
  handler       = "s3_encryption_check.handler"
  role          = var.role_arn
  filename      = "${path.module}/s3_encryption_check.zip"
  timeout       = 30
}

resource "aws_lambda_function" "snapshot_cleanup" {
  function_name = "rds-snapshot-cleanup"
  runtime       = "python3.12"
  handler       = "snapshot_cleanup.handler"
  role          = var.role_arn
  filename      = "${path.module}/snapshot_cleanup.zip"
  timeout       = 60
}

resource "aws_cloudwatch_event_rule" "daily_auto_tag" {
  name                = "daily-auto-tag"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_rule" "daily_s3_check" {
  name                = "daily-s3-check"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_rule" "weekly_snapshot_cleanup" {
  name                = "weekly-snapshot-cleanup"
  schedule_expression = "rate(7 days)"
}
