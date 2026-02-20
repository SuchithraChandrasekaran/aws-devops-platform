# Policy for CloudWatch Logs write access
resource "aws_iam_policy" "cloudwatch_logs_write" {
  name        = "${var.project_name}-cloudwatch-logs-write"
  description = "Allow writing to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:*:*:log-group:/aws/${var.project_name}/*",
          "arn:aws:logs:*:*:log-group:/aws/${var.project_name}/*:*"
        ]
      }
    ]
  })

  tags = {
    Environment = var.environment
    Day         = "22"
    Purpose     = "CloudWatch Logs"
  }
}
