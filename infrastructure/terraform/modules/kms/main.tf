# KMS key for encrypting secrets
resource "aws_kms_key" "secrets" {
  description             = "KMS key for encrypting application secrets"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Environment = var.environment
    Day         = "23"
    Purpose     = "Secrets Encryption"
  }
}

# KMS key alias for easier reference
resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.project_name}-secrets-key"
  target_key_id = aws_kms_key.secrets.key_id
}

# KMS key policy
resource "aws_kms_key_policy" "secrets" {
  key_id = aws_kms_key.secrets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::000000000000:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow services to use the key"
        Effect = "Allow"
        Principal = {
          Service = [
            "secretsmanager.amazonaws.com",
            "ssm.amazonaws.com"
          ]
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
      }
    ]
  })
}
