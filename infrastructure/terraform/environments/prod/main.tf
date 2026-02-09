# Prod Environment Configuration

terraform {
  backend "local" {
    path = "terraform-prod.tfstate"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  environment             = var.environment
  vpc_cidr                = var.vpc_cidr
  public_subnet_1_cidr    = var.public_subnet_1_cidr
  public_subnet_2_cidr    = var.public_subnet_2_cidr
  az1                     = var.az1
  az2                     = var.az2
  enable_flow_logs        = var.enable_flow_logs

  common_tags = {
    Environment = var.environment
    Project     = "AWS DevOps Platform"
    ManagedBy   = "Terraform"
    Day         = "11"
  }
}
