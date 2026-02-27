# IAM role for Lambda functions
resource "aws_iam_role" "lambda_automation" {
  name = "${var.project_name}-lambda-automation-role"

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

# IAM policy for Lambda functions
resource "aws_iam_role_policy" "lambda_automation" {
  name = "${var.project_name}-lambda-automation-policy"
  role = aws_iam_role.lambda_automation.id

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
          "ec2:DescribeInstanceStatus",
          "ec2:StopInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:CreateTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "rds:StopDBInstance",
          "rds:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
          "s3:HeadBucket",
          "s3:PutBucketTagging",
          "s3:PutBucketEncryption",
          "s3:PutPublicAccessBlock"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:ListAttachedUserPolicies",
          "iam:DetachUserPolicy"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "backup:ListBackupJobs",
          "backup:ListRecoveryPointsByBackupVault"
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

# Lambda function - Auto Stop Resources
resource "aws_lambda_function" "auto_stop_resources" {
  filename      = "${path.module}/lambda-packages/auto_stop_resources.zip"
  function_name = "${var.project_name}-auto-stop-resources"
  role          = aws_iam_role.lambda_automation.arn
  handler       = "auto_stop_resources.lambda_handler"
  runtime       = "python3.11"
  timeout       = 300

  environment {
    variables = {
      PROJECT_NAME = var.project_name
    }
  }
}

# Lambda function - Auto Tag
resource "aws_lambda_function" "auto_tag" {
  filename      = "${path.module}/lambda-packages/auto_tag.zip"
  function_name = "${var.project_name}-auto-tag"
  role          = aws_iam_role.lambda_automation.arn
  handler       = "auto_tag.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60

  environment {
    variables = {
      PROJECT_NAME = var.project_name
    }
  }
}

# Lambda function - Backup Verify
resource "aws_lambda_function" "backup_verify" {
  filename      = "${path.module}/lambda-packages/backup_verify.zip"
  function_name = "${var.project_name}-backup-verify"
  role          = aws_iam_role.lambda_automation.arn
  handler       = "backup_verify.lambda_handler"
  runtime       = "python3.11"
  timeout       = 120

  environment {
    variables = {
      PROJECT_NAME = var.project_name
    }
  }
}

# Lambda function - Security Remediation
resource "aws_lambda_function" "security_remediation" {
  filename      = "${path.module}/lambda-packages/security_remediation.zip"
  function_name = "${var.project_name}-security-remediation"
  role          = aws_iam_role.lambda_automation.arn
  handler       = "security_remediation.lambda_handler"
  runtime       = "python3.11"
  timeout       = 120

  environment {
    variables = {
      PROJECT_NAME = var.project_name
    }
  }
}

# Lambda function - Health Check
resource "aws_lambda_function" "health_check" {
  filename      = "${path.module}/lambda-packages/health_check.zip"
  function_name = "${var.project_name}-health-check"
  role          = aws_iam_role.lambda_automation.arn
  handler       = "health_check.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60

  environment {
    variables = {
      PROJECT_NAME = var.project_name
    }
  }
}

# EventBridge rule - Auto Stop (runs at 6 PM daily)
resource "aws_cloudwatch_event_rule" "auto_stop" {
  name                = "${var.project_name}-auto-stop-schedule"
  description         = "Trigger auto-stop at 6 PM daily"
  schedule_expression = "cron(0 18 * * ? *)"
}

resource "aws_cloudwatch_event_target" "auto_stop" {
  rule      = aws_cloudwatch_event_rule.auto_stop.name
  target_id = "AutoStopLambda"
  arn       = aws_lambda_function.auto_stop_resources.arn
}

resource "aws_lambda_permission" "auto_stop" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_stop_resources.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.auto_stop.arn
}

# EventBridge rule - Health Check (runs every 5 minutes)
resource "aws_cloudwatch_event_rule" "health_check" {
  name                = "${var.project_name}-health-check-schedule"
  description         = "Trigger health check every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "health_check" {
  rule      = aws_cloudwatch_event_rule.health_check.name
  target_id = "HealthCheckLambda"
  arn       = aws_lambda_function.health_check.arn
}

resource "aws_lambda_permission" "health_check" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.health_check.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.health_check.arn
}

# EventBridge rule - Backup Verify (runs daily at 9 AM)
resource "aws_cloudwatch_event_rule" "backup_verify" {
  name                = "${var.project_name}-backup-verify-schedule"
  description         = "Trigger backup verification daily at 9 AM"
  schedule_expression = "cron(0 9 * * ? *)"
}

resource "aws_cloudwatch_event_target" "backup_verify" {
  rule      = aws_cloudwatch_event_rule.backup_verify.name
  target_id = "BackupVerifyLambda"
  arn       = aws_lambda_function.backup_verify.arn
}

resource "aws_lambda_permission" "backup_verify" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backup_verify.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.backup_verify.arn
}
