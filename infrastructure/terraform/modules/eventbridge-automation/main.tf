data "aws_region" "current" {}


# IAM role for event handler Lambdas
resource "aws_iam_role" "event_handler" {
  name = "${var.project_name}-event-handler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM policy for event handlers
resource "aws_iam_role_policy" "event_handler" {
  name = "${var.project_name}-event-handler-policy"
  role = aws_iam_role.event_handler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSubnets",
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutBucketEncryption",
          "s3:PutBucketVersioning",
          "s3:PutPublicAccessBlock"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:ListAttachedUserPolicies",
          "iam:ListAttachedRolePolicies"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:DescribeAlarms"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "arn:aws:sns:*:*:*-alerts"
      }
    ]
  })
}

# Lambda functions
resource "aws_lambda_function" "ec2_handler" {
  filename      = "${path.module}/lambda-packages/ec2_handler.zip"
  function_name = "${var.project_name}-ec2-event-handler"
  role          = aws_iam_role.event_handler.arn
  handler       = "ec2_handler.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60
}

resource "aws_lambda_function" "s3_security_handler" {
  filename      = "${path.module}/lambda-packages/s3_security_handler.zip"
  function_name = "${var.project_name}-s3-security-handler"
  role          = aws_iam_role.event_handler.arn
  handler       = "s3_security_handler.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60
}

resource "aws_lambda_function" "iam_audit_handler" {
  filename      = "${path.module}/lambda-packages/iam_audit_handler.zip"
  function_name = "${var.project_name}-iam-audit-handler"
  role          = aws_iam_role.event_handler.arn
  handler       = "iam_audit_handler.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60
}

resource "aws_lambda_function" "alarm_handler" {
  filename      = "${path.module}/lambda-packages/alarm_handler.zip"
  function_name = "${var.project_name}-alarm-handler"
  role          = aws_iam_role.event_handler.arn
  handler       = "alarm_handler.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60
}

# Lambda permissions for EventBridge
resource "aws_lambda_permission" "ec2_handler" {
  for_each = toset([
    aws_cloudwatch_event_rule.ec2_state_change.name,
    aws_cloudwatch_event_rule.ec2_launch.name
  ])
  
  statement_id  = "AllowEventBridge${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_handler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:${data.aws_region.current.name}:000000000000:rule/${each.key}"
}

resource "aws_lambda_permission" "s3_security_handler" {
  for_each = toset([
    aws_cloudwatch_event_rule.s3_bucket_created.name,
    aws_cloudwatch_event_rule.s3_public_access.name
  ])
  
  statement_id  = "AllowEventBridge${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_security_handler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:${data.aws_region.current.name}:000000000000:rule/${each.key}"
}

resource "aws_lambda_permission" "iam_audit_handler" {
  for_each = toset([
    aws_cloudwatch_event_rule.iam_policy_change.name,
    aws_cloudwatch_event_rule.root_account_usage.name
  ])
  
  statement_id  = "AllowEventBridge${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.iam_audit_handler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:${data.aws_region.current.name}:000000000000:rule/${each.key}"
}

resource "aws_lambda_permission" "alarm_handler" {
  statement_id  = "AllowEventBridgeAlarmHandler"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alarm_handler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.alarm_state_change.arn
}
