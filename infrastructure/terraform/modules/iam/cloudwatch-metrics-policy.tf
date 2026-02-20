# Policy for CloudWatch Metrics write access
resource "aws_iam_policy" "cloudwatch_metrics_write" {
  name        = "${var.project_name}-cloudwatch-metrics-write"
  description = "Allow publishing CloudWatch metrics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "cloudwatch:namespace" = [
              "MyApp/Metrics",
              "MyApp/Logs"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Day         = "22"
    Purpose     = "CloudWatch Metrics"
  }
}
