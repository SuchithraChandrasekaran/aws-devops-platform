output "config_recorder_id" {
  description = "Config recorder ID"
  value       = aws_config_configuration_recorder.main.id
}

output "config_bucket_name" {
  description = "Config S3 bucket name"
  value       = aws_s3_bucket.config.bucket
}

output "config_rules" {
  description = "Config rule names"
  value = {
    s3_encryption    = aws_config_config_rule.s3_bucket_encryption.name
    cloudtrail       = aws_config_config_rule.cloudtrail_enabled.name
    approved_amis    = aws_config_config_rule.approved_amis.name
    iam_password     = aws_config_config_rule.iam_password_policy.name
    rds_encryption   = aws_config_config_rule.rds_encryption.name
  }
}
