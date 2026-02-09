# Terraform Workspaces

## What are Workspaces?

Workspaces allow multiple state files within the same configuration directory.

Default workspace: `default`

## Use Cases

1. Multiple environments (dev, staging, prod) with same code
2. Feature branch testing
3. Temporary infrastructure
4. A/B testing infrastructure changes

## Workspace Commands
```bash
# List workspaces (* shows current)
terraform workspace list

# Create new workspace
terraform workspace new dev

# Switch workspace
terraform workspace select dev

# Show current workspace
terraform workspace show

# Delete workspace
terraform workspace delete dev
```

## How Workspaces Work

### Local Backend
Creates separate state files:
terraform.tfstate.d/
├── dev/
│   └── terraform.tfstate
└── prod/
└── terraform.tfstate

### Remote Backend (S3)
Uses key prefix:
env:/dev/path/to/terraform.tfstate
env:/prod/path/to/terraform.tfstate

## Using Workspaces in Configuration
```hcl
locals {
  environment = terraform.workspace
}

resource "aws_instance" "app" {
  instance_type = local.environment == "prod" ? "t3.large" : "t3.micro"
  
  tags = {
    Name        = "app-${terraform.workspace}"
    Environment = terraform.workspace
  }
}
```

## Workspace Best Practices

### When to Use Workspaces

- Same configuration for multiple environments
- Temporary testing environments
- Quick environment duplication

### When NOT to Use Workspaces

- Different configurations per environment
- Need separate backend per environment
- Team collaboration with different permissions

### Better Alternatives

For production environments, use:
1. Separate directories per environment
2. Separate state files per environment
3. Different backend configurations

environments/
├── dev/
│   ├── main.tf
│   └── backend.tf
└── prod/
├── main.tf
└── backend.tf

## Workspace Limitations

1. All workspaces share same backend configuration
2. All workspaces share same Terraform code
3. Easy to accidentally affect wrong workspace
4. Workspace name must be used in tags for tracking
5. No built-in RBAC per workspace

## Workspace Examples

### Example 1: Multi-Environment Setup
```hcl
variable "instance_sizes" {
  type = map(string)
  default = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.large"
  }
}

resource "aws_instance" "app" {
  instance_type = var.instance_sizes[terraform.workspace]
  
  tags = {
    Name        = "app-${terraform.workspace}"
    Environment = terraform.workspace
  }
}
```

Workflow:
```bash
# Deploy to dev
terraform workspace select dev
terraform apply

# Deploy to prod
terraform workspace select prod
terraform apply
```

### Example 2: Feature Branch Testing
```bash
# Create feature workspace
terraform workspace new feature-auth

# Deploy feature infrastructure
terraform apply

# Test feature

# Clean up
terraform destroy
terraform workspace select default
terraform workspace delete feature-auth
```

### Example 3: Conditional Resources
```hcl
resource "aws_instance" "bastion" {
  count = terraform.workspace == "prod" ? 1 : 0
  
  instance_type = "t3.micro"
  
  tags = {
    Name = "bastion-${terraform.workspace}"
  }
}
```

## Workspace State Isolation

Each workspace has completely separate state:
```bash
# In default workspace
terraform state list
# Shows: aws_vpc.main, aws_subnet.public

# Switch to dev workspace
terraform workspace select dev
terraform state list
# Empty or different resources
```

Resources in one workspace don't affect other workspace

## Summary

Workspaces:
- Good for: Temporary environments, testing, same config
- Bad for: Production, different configs, team permissions

Directory-based environments:
- Good for: Production, different configs, clear separation
- Bad for: Quick testing, code duplication

