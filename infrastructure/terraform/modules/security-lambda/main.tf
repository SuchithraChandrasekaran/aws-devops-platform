# IAM role for Lambda functions
resource "aws_iam_role" "security_lambda" {
  name = "${var.project_name}-security-lambda-role"

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

# IAM policy for Lambda
resource "aws_iam_role_policy" "security_lambda" {
  name = "${var.project_name}-security-lambda-policy"
  role = aws_iam_role.security_lambda.id

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
          "ec2:DescribeSecurityGroups",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:ModifyInstanceAttribute"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:ListAttachedUserPolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListUserPolicies",
          "iam:ListRolePolicies",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:GetUserPolicy",
          "iam:DetachUserPolicy",
          "iam:DetachRolePolicy",
          "iam:DeleteUserPolicy"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutBucketEncryption",
          "s3:PutBucketPublicAccessBlock",
          "s3:PutBucketVersioning",
          "s3:PutBucketLogging"
        ]
        Resource = "*"
      }
    ]
  })
}

# Security Group Remediation Lambda
resource "aws_lambda_function" "sg_remediation" {
  filename      = "${path.module}/lambda-packages/sg_remediation.zip"
  function_name = "${var.project_name}-sg-remediation"
  role          = aws_iam_role.security_lambda.arn
  handler       = "sg_remediation.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60

  environment {
    variables = {
      PROJECT_NAME = var.project_name
    }
  }
}

# IAM Remediation Lambda
resource "aws_lambda_function" "iam_remediation" {
  filename      = "${path.module}/lambda-packages/iam_remediation.zip"
  function_name = "${var.project_name}-iam-remediation"
  role          = aws_iam_role.security_lambda.arn
  handler       = "iam_remediation.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60

  environment {
    variables = {
      PROJECT_NAME = var.project_name
    }
  }
}

# S3 Remediation Lambda
resource "aws_lambda_function" "s3_remediation" {
  filename      = "${path.module}/lambda-packages/s3_remediation.zip"
  function_name = "${var.project_name}-s3-remediation"
  role          = aws_iam_role.security_lambda.arn
  handler       = "s3_remediation.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60

  environment {
    variables = {
      PROJECT_NAME = var.project_name
    }
  }
}

# EventBridge rule for security findings
resource "aws_cloudwatch_event_rule" "security_findings" {
  name        = "${var.project_name}-security-findings"
  description = "Capture security findings for auto-remediation"

  event_pattern = jsonencode({
    source      = ["aws.guardduty", "aws.securityhub"]
    detail-type = ["GuardDuty Finding", "Security Hub Findings - Imported"]
  })
}

# EventBridge target - Security Group remediation
resource "aws_cloudwatch_event_target" "sg_remediation" {
  rule      = aws_cloudwatch_event_rule.security_findings.name
  target_id = "SecurityGroupRemediation"
  arn       = aws_lambda_function.sg_remediation.arn
}

# EventBridge target - IAM remediation
resource "aws_cloudwatch_event_target" "iam_remediation" {
  rule      = aws_cloudwatch_event_rule.security_findings.name
  target_id = "IAMRemediation"
  arn       = aws_lambda_function.iam_remediation.arn
}

# EventBridge target - S3 remediation
resource "aws_cloudwatch_event_target" "s3_remediation" {
  rule      = aws_cloudwatch_event_rule.security_findings.name
  target_id = "S3Remediation"
  arn       = aws_lambda_function.s3_remediation.arn
}

# Lambda permissions for EventBridge
resource "aws_lambda_permission" "sg_remediation" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sg_remediation.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.security_findings.arn
}

resource "aws_lambda_permission" "iam_remediation" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.iam_remediation.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.security_findings.arn
}

resource "aws_lambda_permission" "s3_remediation" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_remediation.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.security_findings.arn
}
