# Database credentials secret
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}/database/credentials"
  description             = "Database connection credentials"
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = 7

  tags = {
    Environment = var.environment
    Day         = "23"
    Type        = "database"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = "ChangeMeInProduction123!"
    host     = "localhost"
    port     = 5432
    database = "myapp"
  })
}

# API keys secret
resource "aws_secretsmanager_secret" "api_keys" {
  name                    = "${var.project_name}/api/keys"
  description             = "Third-party API keys"
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = 7

  tags = {
    Environment = var.environment
    Day         = "23"
    Type        = "api"
  }
}

resource "aws_secretsmanager_secret_version" "api_keys" {
  secret_id = aws_secretsmanager_secret.api_keys.id
  secret_string = jsonencode({
    stripe_key    = "sk_test_4eC39HqLyjWDarjtT1zdp7dc"
    sendgrid_key  = "SG.1234567890abcdefghij"
    github_token  = "ghp_1234567890abcdefghijklmnopqrst"
  })
}

# Application config secret
resource "aws_secretsmanager_secret" "app_config" {
  name                    = "${var.project_name}/app/config"
  description             = "Application configuration secrets"
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = 7

  tags = {
    Environment = var.environment
    Day         = "23"
    Type        = "config"
  }
}

resource "aws_secretsmanager_secret_version" "app_config" {
  secret_id = aws_secretsmanager_secret.app_config.id
  secret_string = jsonencode({
    jwt_secret     = "super-secret-jwt-key-change-me"
    encryption_key = "aes-256-encryption-key-change-me"
    session_secret = "session-secret-key-change-me"
  })
}

# SSL/TLS certificates secret
resource "aws_secretsmanager_secret" "certificates" {
  name                    = "${var.project_name}/certificates/ssl"
  description             = "SSL/TLS certificates"
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = 7

  tags = {
    Environment = var.environment
    Day         = "23"
    Type        = "certificates"
  }
}

resource "aws_secretsmanager_secret_version" "certificates" {
  secret_id = aws_secretsmanager_secret.certificates.id
  secret_string = jsonencode({
    certificate = "-----BEGIN CERTIFICATE-----\nMIIC...\n-----END CERTIFICATE-----"
    private_key = "-----BEGIN PRIVATE KEY-----\nMIIE...\n-----END PRIVATE KEY-----"
    ca_bundle   = "-----BEGIN CERTIFICATE-----\nMIID...\n-----END CERTIFICATE-----"
  })
}
