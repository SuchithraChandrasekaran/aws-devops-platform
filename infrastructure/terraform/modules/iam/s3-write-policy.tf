# Policy for S3 write access
resource "aws_iam_policy" "s3_write" {
  name        = "${var.project_name}-s3-write"
  description = "Allow write access to specific S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-*/*"
        ]
      }
    ]
  })

  tags = {
    Environment = var.environment
    Day         = "22"
    Purpose     = "S3 Write"
  }
}
