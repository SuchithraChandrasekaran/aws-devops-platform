output "db_credentials_arn" {
  description = "Database credentials secret ARN"
  value       = aws_secretsmanager_secret.db_credentials.arn
  sensitive   = true
}

output "api_keys_arn" {
  description = "API keys secret ARN"
  value       = aws_secretsmanager_secret.api_keys.arn
  sensitive   = true
}

output "app_config_arn" {
  description = "App config secret ARN"
  value       = aws_secretsmanager_secret.app_config.arn
  sensitive   = true
}

output "certificates_arn" {
  description = "Certificates secret ARN"
  value       = aws_secretsmanager_secret.certificates.arn
  sensitive   = true
}
