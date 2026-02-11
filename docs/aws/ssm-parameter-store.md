# AWS Systems Manager Parameter Store Guide

## Overview

Parameter Store provides secure, hierarchical storage for configuration data and secrets management.

## Key Concepts

### Parameter Types

1. **String**
   - Plain text values
   - No encryption
   - Use for non-sensitive data

2. **StringList**
   - Comma-separated values
   - Treated as single parameter
   - Example: "value1,value2,value3"

3. **SecureString**
   - Encrypted with KMS
   - For sensitive data
   - Auto-decrypted when retrieved with proper permissions

### Parameter Tiers

1. **Standard**
   - Free
   - Up to 4KB value size
   - 10,000 parameters per account
   - No parameter policies

2. **Advanced**
   - Charges apply
   - Up to 8KB value size
   - 100,000 parameters per account
   - Parameter policies supported

### Naming Hierarchy

Use forward slashes to create hierarchy:
```
/environment/application/component/key

Examples:
/dev/app/database/host
/dev/app/database/port
/prod/app/api/endpoint
```

Benefits:
- Organized configuration
- Bulk retrieval by path
- IAM policy by hierarchy level
- Clear ownership and purpose

## Common Operations

### Create Parameter
```bash
aws ssm put-parameter \
    --name "/dev/app/database/host" \
    --value "localhost" \
    --type String \
    --description "Database host"
```

### Get Parameter
```bash
aws ssm get-parameter \
    --name "/dev/app/database/host"
```

### Get Parameters by Path
```bash
aws ssm get-parameters-by-path \
    --path "/dev/app" \
    --recursive
```

### Update Parameter
```bash
aws ssm put-parameter \
    --name "/dev/app/database/host" \
    --value "db.example.com" \
    --overwrite
```

## Best Practices

1. **Use Hierarchies** - Organize by environment/app/component
2. **Naming Conventions** - Use lowercase, separate with hyphens
3. **Access Control** - Use IAM policies for parameter access
4. **Versioning** - Track changes with parameter history
5. **Integration** - Reference in application code and IaC

## LocalStack Usage
```bash
aws ssm get-parameter \
    --name "/dev/app/version" \
    --endpoint-url=http://localhost:4566 \
    --profile localstack
```

## Terraform Integration
```hcl
# Read existing parameter
data "aws_ssm_parameter" "db_host" {
  name = "/dev/app/database/host"
}

# Create parameter
resource "aws_ssm_parameter" "config" {
  name  = "/dev/app/version"
  type  = "String"
  value = "1.0.0"
}
```
