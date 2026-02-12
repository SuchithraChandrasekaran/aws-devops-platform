# CloudWatch Monitoring Module
module "cloudwatch" {
  source = "./modules/cloudwatch"

  environment         = var.environment
  log_retention_days = 7
}
