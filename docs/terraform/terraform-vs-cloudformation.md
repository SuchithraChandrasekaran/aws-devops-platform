# Terraform vs CloudFormation

## Comparison Matrix

| Feature | Terraform | CloudFormation |
|---------|-----------|----------------|
| Language | HCL (declarative) | YAML/JSON (declarative) |
| Provider Support | Multi-cloud (AWS, Azure, GCP, etc) | AWS only |
| State Management | Explicit state file | Implicit stack state |
| Modularity | Modules | Nested stacks |
| Plan Preview | terraform plan | Change sets |
| Resource Import | terraform import | Limited import support |
| Community | Large 3rd-party providers | AWS-maintained only |
| Learning Curve | Moderate | Easy for AWS users |

## When to Use Terraform

- Multi-cloud deployments
- Need provider ecosystem
- Want explicit state control
- Prefer HCL syntax
- Need strong module system

## When to Use CloudFormation

- AWS-only infrastructure
- Native AWS integration needed
- Team familiar with YAML/JSON
- Want AWS-managed state
- StackSets for multi-account

## Syntax Comparison

CloudFormation:
```yaml
Resources:
  MyVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
```

Terraform:
```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
```

## Key Differences

### State
- CloudFormation: AWS manages state automatically
- Terraform: You manage state file (local or remote)

### Modularity
- CloudFormation: Nested stacks with parent/child relationship
- Terraform: Modules called like functions

### Updates
- CloudFormation: Change sets show preview
- Terraform: Plan shows detailed diff

### Outputs
- CloudFormation: Exports for cross-stack references
- Terraform: Outputs can be used by other configs

Both are valid IaC tools - choice depends on requirements and team preferences.
