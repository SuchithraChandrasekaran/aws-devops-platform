
module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
}

module "ec2" {
  source       = "./modules/ec2"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  subnet_id    = module.vpc.public_subnet_id
  key_name     = "aws-devops-key"
  my_ip        = var.my_ip
}
