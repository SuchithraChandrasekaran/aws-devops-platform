# Terraform Modules Best Practices

## Module Structure
modules/
└── vpc/
├── main.tf       # Resources
├── variables.tf  # Input variables
├── outputs.tf    # Output values
└── README.md     # Documentation
## Module Design Principles

1. Single Responsibility
   - Each module should do one thing well
   - VPC module handles networking only

2. Composability
   - Modules should work together
   - Pass outputs from one module as inputs to another

3. Reusability
   - Design for multiple environments
   - Use variables for environment-specific values

4. Documentation
   - README with usage examples
   - Comment complex logic

## Variable Best Practices

- Provide sensible defaults
- Use validation rules
- Group related variables
- Use descriptive names
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Must be dev or prod."
  }
}
```

## Output Best Practices

- Output values other modules might need
- Use descriptions
- Consider sensitive flag for secrets
```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}
```

## Module Versioning

For shared modules:
- Use git tags for versions
- Follow semantic versioning
- Document breaking changes

## Calling Modules
```hcl
module "vpc" {
  source = "../../modules/vpc"
  
  environment = "dev"
  vpc_cidr    = "10.0.0.0/16"
}

# Reference module outputs
resource "aws_instance" "app" {
  subnet_id = module.vpc.public_subnet_1_id
}
```

## Remote Modules

Can source from:
- Local paths: `./modules/vpc`
- Git: `git::https://github.com/user/repo.git//modules/vpc`
- Terraform Registry: `terraform-aws-modules/vpc/aws`

## Testing Modules

- Test in dev environment first
- Use terraform validate
- Run terraform plan to preview
- Consider automated testing with Terratest
