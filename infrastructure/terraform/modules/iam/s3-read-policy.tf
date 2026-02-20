# Policy for S3 read-only access
resource "aws_iam_policy" "s3_read_only" {
  name        = "${var.project_name}-s3-read-only"
  description = "Allow read-only access to specific S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-*",
          "arn:aws:s3:::${var.project_name}-*/*"
        ]
      }
    ]
  })

  tags = {
    Environment = var.environment
    Day         = "22"
    Purpose     = "S3 Read"
  }
}
