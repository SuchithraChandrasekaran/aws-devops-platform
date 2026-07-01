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
    username = var.db_username
    password = var.db_password
    host     = var.db_host
    port     = var.db_port
    database = var.db_name
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
    stripe_key    = "sk_test_PLACEHOLDER"
    sendgrid_key  = "SG.PLACEHOLDER"
    github_token  = "ghp_PLACEHOLDER"
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
    jwt_secret     = var.jwt_secret
    encryption_key = var.encryption_key
    session_secret = var.session_secret
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
