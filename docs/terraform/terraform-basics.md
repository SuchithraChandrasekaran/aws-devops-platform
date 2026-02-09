# Terraform Basics

## Core Workflow

1. Write - Author infrastructure as code
2. Init - Initialize working directory
3. Plan - Preview changes
4. Apply - Create infrastructure
5. Destroy - Clean up resources

## Key Concepts

### Providers
Plugins that interact with cloud APIs. Each provider has its own resources and data sources.
```hcl
provider "aws" {
  region = "us-east-1"
}
```

### Resources
Infrastructure components to create/manage.
```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
```

### Variables
Input values for configurations.
```hcl
variable "environment" {
  type    = string
  default = "dev"
}
```

### Outputs
Values to expose after deployment.
```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}
```

### Modules
Reusable configuration containers.
```hcl
module "vpc" {
  source = "./modules/vpc"
  
  environment = "dev"
}
```

## HCL Syntax

HashiCorp Configuration Language:
- Blocks define resources
- Arguments set values
- Expressions compute values
- Comments use # or //

## State File

Tracks real infrastructure state:
- JSON format mapping config to resources
- Contains sensitive data - secure it
- Used for plan/apply operations
- Can be local or remote

## Commands

- `terraform init` - Initialize directory
- `terraform plan` - Show execution plan
- `terraform apply` - Apply changes
- `terraform destroy` - Destroy infrastructure
- `terraform output` - Show outputs
- `terraform state list` - List resources
- `terraform fmt` - Format code
- `terraform validate` - Validate syntax
