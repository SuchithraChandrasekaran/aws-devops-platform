# Background worker service role
resource "aws_iam_role" "worker_service" {
  name = "${var.project_name}-worker-service-role"

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
    Service     = "worker"
  }
}

# Attach policies to worker role
resource "aws_iam_role_policy_attachment" "worker_cloudwatch_logs" {
  role       = aws_iam_role.worker_service.name
  policy_arn = aws_iam_policy.cloudwatch_logs_write.arn
}

resource "aws_iam_role_policy_attachment" "worker_cloudwatch_metrics" {
  role       = aws_iam_role.worker_service.name
  policy_arn = aws_iam_policy.cloudwatch_metrics_write.arn
}

resource "aws_iam_role_policy_attachment" "worker_s3_write" {
  role       = aws_iam_role.worker_service.name
  policy_arn = aws_iam_policy.s3_write.arn
}

resource "aws_iam_role_policy_attachment" "worker_eventbridge" {
  role       = aws_iam_role.worker_service.name
  policy_arn = aws_iam_policy.eventbridge_put_events.arn
}
