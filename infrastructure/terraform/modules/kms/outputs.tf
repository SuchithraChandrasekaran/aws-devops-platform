output "kms_key_id" {
  description = "KMS key ID"
  value       = aws_kms_key.secrets.key_id
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.secrets.arn
}

output "kms_alias_name" {
  description = "KMS key alias"
  value       = aws_kms_alias.secrets.name
}
