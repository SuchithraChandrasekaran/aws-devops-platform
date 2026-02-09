# VPC Terraform Module

This module creates a VPC with public subnets across two availability zones.

## Resources Created

- VPC with DNS support
- Internet Gateway
- 2 Public Subnets
- Public Route Table with IGW route
- Route Table Associations
- Optional VPC Flow Logs

## Usage
```hcl
module "vpc" {
  source = "../../modules/vpc"

  environment             = "dev"
  vpc_cidr                = "10.0.0.0/16"
  public_subnet_1_cidr    = "10.0.1.0/24"
  public_subnet_2_cidr    = "10.0.2.0/24"
  az1                     = "us-east-1a"
  az2                     = "us-east-1b"
  enable_flow_logs        = false

  common_tags = {
    Project     = "AWS DevOps Platform"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | Environment name | string | - | yes |
| vpc_cidr | VPC CIDR block | string | 10.0.0.0/16 | no |
| public_subnet_1_cidr | Public subnet 1 CIDR | string | 10.0.1.0/24 | no |
| public_subnet_2_cidr | Public subnet 2 CIDR | string | 10.0.2.0/24 | no |
| az1 | Availability zone 1 | string | us-east-1a | no |
| az2 | Availability zone 2 | string | us-east-1b | no |
| enable_flow_logs | Enable VPC flow logs | bool | false | no |
| common_tags | Common resource tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | VPC ID |
| vpc_cidr | VPC CIDR block |
| public_subnet_1_id | Public subnet 1 ID |
| public_subnet_2_id | Public subnet 2 ID |
| internet_gateway_id | Internet Gateway ID |
| public_route_table_id | Public route table ID |
