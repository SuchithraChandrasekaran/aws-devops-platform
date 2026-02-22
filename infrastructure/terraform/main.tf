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
