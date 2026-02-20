# Monitoring service role
resource "aws_iam_role" "monitoring_service" {
  name = "${var.project_name}-monitoring-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Day         = "22"
    Service     = "monitoring"
  }
}

# Attach policies to monitoring role
resource "aws_iam_role_policy_attachment" "monitoring_sns" {
  role       = aws_iam_role.monitoring_service.name
  policy_arn = aws_iam_policy.sns_publish.arn
}

resource "aws_iam_role_policy_attachment" "monitoring_cloudwatch_logs" {
  role       = aws_iam_role.monitoring_service.name
  policy_arn = aws_iam_policy.cloudwatch_logs_write.arn
}
