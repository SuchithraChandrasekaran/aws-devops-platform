# Application service role
resource "aws_iam_role" "application_service" {
  name = "${var.project_name}-application-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Day         = "22"
    Service     = "application"
  }
}

# Attach policies to application role
resource "aws_iam_role_policy_attachment" "app_cloudwatch_logs" {
  role       = aws_iam_role.application_service.name
  policy_arn = aws_iam_policy.cloudwatch_logs_write.arn
}

resource "aws_iam_role_policy_attachment" "app_cloudwatch_metrics" {
  role       = aws_iam_role.application_service.name
  policy_arn = aws_iam_policy.cloudwatch_metrics_write.arn
}

resource "aws_iam_role_policy_attachment" "app_s3_read" {
  role       = aws_iam_role.application_service.name
  policy_arn = aws_iam_policy.s3_read_only.arn
}
