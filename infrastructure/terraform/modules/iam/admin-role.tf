# Admin role with elevated permissions (use sparingly)
resource "aws_iam_role" "admin" {
  name = "${var.project_name}-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::000000000000:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "admin-access-${var.environment}"
          }
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Day         = "22"
    Service     = "admin"
  }
}

# Admin policy - limited admin access
resource "aws_iam_policy" "admin_policy" {
  name        = "${var.project_name}-admin-policy"
  description = "Limited admin permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:*",
          "logs:*",
          "sns:*",
          "events:*",
          "s3:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Deny"
        Action = [
          "iam:DeleteRole",
          "iam:DeletePolicy",
          "iam:DeleteUser"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Day         = "22"
  }
}

resource "aws_iam_role_policy_attachment" "admin_attach" {
  role       = aws_iam_role.admin.name
  policy_arn = aws_iam_policy.admin_policy.arn
}
