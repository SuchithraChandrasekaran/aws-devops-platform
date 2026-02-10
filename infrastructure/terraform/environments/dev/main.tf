# Dev Environment Configuration
# Backend configured in backend.tf

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

# Expose VPC module outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_1_id" {
  description = "ID of public subnet 1"
  value       = module.vpc.public_subnet_1_id
}

output "public_subnet_2_id" {
  description = "ID of public subnet 2"
  value       = module.vpc.public_subnet_2_id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = module.vpc.public_route_table_id
}
