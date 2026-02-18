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
