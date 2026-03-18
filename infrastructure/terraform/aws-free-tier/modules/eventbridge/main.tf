variable "sns_topic_arn" {
  type = string
}

variable "ec2_instance_id" {
  type    = string
  default = "i-0eea9312c1d8fc04a"
}

# Rule 1 - nightly EC2 stop
resource "aws_cloudwatch_event_rule" "auto_stop_ec2" {
  name                = "auto-stop-ec2-nightly"
  description         = "Stop EC2 instance at 11 PM UTC daily"
  schedule_expression = "cron(0 23 * * ? *)"
}

resource "aws_cloudwatch_event_target" "auto_stop_ec2" {
  rule = aws_cloudwatch_event_rule.auto_stop_ec2.name
  arn  = aws_lambda_function.auto_stop_ec2.arn
  target_id = "stop-ec2-target"
}

# Rule 2 - EC2 state change
resource "aws_cloudwatch_event_rule" "ec2_state_change" {
  name        = "ec2-state-change-notify"
  description = "Notify on EC2 state changes"
  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      instance-id = [var.ec2_instance_id]
      state       = ["running", "stopped", "terminated"]
    }
  })
}

resource "aws_cloudwatch_event_target" "ec2_state_change" {
  rule      = aws_cloudwatch_event_rule.ec2_state_change.name
  arn       = var.sns_topic_arn
  target_id = "sns-target"
}

# Rule 3 - RDS events
resource "aws_cloudwatch_event_rule" "rds_events" {
  name        = "rds-events-notify"
  description = "Notify on RDS events"
  event_pattern = jsonencode({
    source      = ["aws.rds"]
    detail-type = ["RDS DB Instance Event"]
    detail = {
      SourceIdentifier = ["aws-devops-db"]
    }
  })
}

resource "aws_cloudwatch_event_target" "rds_events" {
  rule      = aws_cloudwatch_event_rule.rds_events.name
  arn       = var.sns_topic_arn
  target_id = "sns-rds-target"
}

# Rule 4 - health check
resource "aws_cloudwatch_event_rule" "health_check" {
  name                = "infra-health-check"
  description         = "Run infrastructure health check every 30 minutes"
  schedule_expression = "rate(30 minutes)"
}

resource "aws_cloudwatch_event_target" "health_check" {
  rule      = aws_cloudwatch_event_rule.health_check.name
  arn       = aws_lambda_function.health_check.arn
  target_id = "health-check-target"
}

# Lambda functions
resource "aws_lambda_function" "auto_stop_ec2" {
  function_name    = "auto-stop-ec2"
  runtime          = "python3.12"
  handler          = "auto_stop_ec2.handler"
  role             = aws_iam_role.lambda_role.arn
  filename         = "${path.module}/auto_stop_ec2.zip"
  timeout          = 30
}

resource "aws_lambda_function" "health_check" {
  function_name    = "infrastructure-health-check"
  runtime          = "python3.12"
  handler          = "health_check.handler"
  role             = aws_iam_role.lambda_role.arn
  filename         = "${path.module}/health_check.zip"
  timeout          = 30
}

resource "aws_iam_role" "lambda_role" {
  name = "aws-devops-eventbridge-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}
