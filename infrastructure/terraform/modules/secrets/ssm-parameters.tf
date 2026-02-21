# SSM Parameter Store for non-secret configuration

# Database endpoint (not encrypted)
resource "aws_ssm_parameter" "db_endpoint" {
  name  = "/${var.project_name}/${var.environment}/database/endpoint"
  type  = "String"
  value = "localhost:5432"

  tags = {
    Environment = var.environment
    Day         = "23"
  }
}

# Database name (not encrypted)
resource "aws_ssm_parameter" "db_name" {
  name  = "/${var.project_name}/${var.environment}/database/name"
  type  = "String"
  value = "myapp"

  tags = {
    Environment = var.environment
    Day         = "23"
  }
}

# Database password (KMS encrypted)
resource "aws_ssm_parameter" "db_password" {
  name   = "/${var.project_name}/${var.environment}/database/password"
  type   = "SecureString"
  value  = "ChangeMeInProduction123!"
  key_id = var.kms_key_id

  tags = {
    Environment = var.environment
    Day         = "23"
  }
}

# API base URL (not encrypted)
resource "aws_ssm_parameter" "api_url" {
  name  = "/${var.project_name}/${var.environment}/api/base_url"
  type  = "String"
  value = "https://api.example.com"

  tags = {
    Environment = var.environment
    Day         = "23"
  }
}

# Feature flags (not encrypted)
resource "aws_ssm_parameter" "feature_flags" {
  name  = "/${var.project_name}/${var.environment}/features/enabled"
  type  = "StringList"
  value = "new-ui,api-v2,analytics"

  tags = {
    Environment = var.environment
    Day         = "23"
  }
}
