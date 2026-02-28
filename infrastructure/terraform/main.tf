# CloudWatch Monitoring Module
module "cloudwatch" {
  source = "./modules/cloudwatch"
  
  environment         = var.environment
  log_retention_days  = 7
  critical_topic_arn  = module.sns.critical_topic_arn
  warning_topic_arn   = module.sns.warning_topic_arn
}

# SNS Module for alerting
module "sns" {
  source = "./modules/sns"
  
  environment = var.environment
  alert_email = var.alert_email
}

# EventBridge Module for event automation
module "eventbridge" {
  source = "./modules/eventbridge"

  environment        = var.environment
  critical_topic_arn = module.sns.critical_topic_arn
  warning_topic_arn  = module.sns.warning_topic_arn
}

# IAM Module for roles and policies
module "iam" {
  source = "./modules/iam"

  environment    = var.environment
  project_name   = var.project_name
}

# KMS Module for encryption keys
module "kms" {
  source = "./modules/kms"

  environment  = var.environment
  project_name = var.project_name
}

# Secrets Manager Module
module "secrets" {
  source = "./modules/secrets"

  environment  = var.environment
  project_name = var.project_name
  kms_key_id   = module.kms.kms_key_id
}

# VPC Module for network security
module "vpc" {
  source = "./modules/vpc"

  environment  = var.environment
  project_name = var.project_name
  aws_region   = var.aws_region
}

# AWS Config Module for compliance monitoring
module "config" {
  source = "./modules/config"

  environment  = var.environment
  project_name = var.project_name
}

# Security Lambda Module for auto-remediation
module "security_lambda" {
  source = "./modules/security-lambda"

  environment  = var.environment
  project_name = var.project_name
}

# Lambda Automation Module
module "lambda_automation" {
  source = "./modules/lambda-automation"

  environment  = var.environment
  project_name = var.project_name
}

# EventBridge Automation Module
module "eventbridge_automation" {
  source = "./modules/eventbridge-automation"

  environment  = var.environment
  project_name = var.project_name

  # Reference Lambda functions from lambda-automation module
  ec2_handler_lambda_arn        = module.lambda_automation.lambda_functions.auto_stop_resources
  auto_tag_lambda_arn           = module.lambda_automation.lambda_functions.auto_tag
  s3_security_lambda_arn        = module.lambda_automation.lambda_functions.security_remediation
  s3_remediation_lambda_arn     = module.lambda_automation.lambda_functions.security_remediation
  iam_audit_lambda_arn          = module.lambda_automation.lambda_functions.security_remediation
  security_alert_lambda_arn     = module.lambda_automation.lambda_functions.security_remediation
  alarm_handler_lambda_arn      = module.lambda_automation.lambda_functions.health_check
  security_audit_lambda_arn     = module.lambda_automation.lambda_functions.auto_stop_resources
}
