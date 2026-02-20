# Policy for SNS publish access
resource "aws_iam_policy" "sns_publish" {
  name        = "${var.project_name}-sns-publish"
  description = "Allow publishing to SNS topics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = [
          "arn:aws:sns:*:*:${var.project_name}-*"
        ]
      }
    ]
  })

  tags = {
    Environment = var.environment
    Day         = "22"
    Purpose     = "SNS Publish"
  }
}
