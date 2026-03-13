locals {
  env    = terraform.workspace == "default" ? var.environment : terraform.workspace
  prefix = "aws-devops-${local.env}"
}
