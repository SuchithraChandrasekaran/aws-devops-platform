# State management concepts
cat > docs/terraform/state-management.md << 'EOF'
# Terraform State Management

## What is State?

Terraform state is a JSON file that maps your configuration to real infrastructure resources.

### State File Contents

- Resource metadata (IDs, ARNs, attributes)
- Resource dependencies
- Provider configuration
- Terraform version used
- Serial number (increments with each change)
- Lineage ID (unique identifier for state file)

### Why State Matters

1. Performance: Caches resource attributes to avoid constant API calls
2. Metadata: Tracks resource dependencies and relationships
3. Resource tracking: Knows which real resources correspond to config
4. Plan accuracy: Compares desired state to current state

## State File Location

### Local Backend (Default)
- State stored in `terraform.tfstate` file
- Simple for single-user workflows
- Risk: State lost if file deleted
- Problem: No collaboration support

### Remote Backend (Recommended)
- State stored remotely (S3, Terraform Cloud, etc)
- Enables team collaboration
- Provides state locking
- Automatic backup and versioning
- Centralized state management

## State Locking

Prevents concurrent state modifications that could corrupt state file.

### How It Works

1. User runs `terraform apply`
2. Terraform acquires lock in DynamoDB
3. Lock includes: timestamp, user info, operation
4. Other users are blocked until lock released
5. After apply completes, lock released

### Lock Record Structure
```json
{
  "LockID": "terraform-state-devops-platform/dev/terraform.tfstate",
  "Info": "user@hostname running plan",
  "Created": "2024-01-01T10:00:00Z",
  "Operation": "OperationTypePlan",
  "Version": "1.6.0"
}
```

## State Commands
```bash
# List resources in state
terraform state list

# Show detailed resource info
terraform state show aws_vpc.main

# Move resource to different path
terraform state mv aws_vpc.main aws_vpc.new_main

# Remove resource from state (doesn't destroy)
terraform state rm aws_vpc.main

# Import existing resource
terraform import aws_vpc.main vpc-12345

# Pull remote state to view
terraform state pull

# Push local state to remote
terraform state push terraform.tfstate
```

## State Security

State files contain sensitive data:
- Resource IDs and ARNs
- Database passwords (if not using secrets)
- Private keys
- API tokens

### Best Practices

1. Never commit state files to git
2. Enable encryption at rest (S3)
3. Enable encryption in transit (HTTPS)
4. Restrict bucket/table access with IAM
5. Enable versioning for recovery
6. Use separate state files per environment
7. Store secrets in dedicated services (Secrets Manager)

## State Drift

When real infrastructure diverges from state file.

### Causes
- Manual changes in AWS console
- Changes made outside Terraform
- Failed apply operations
- External automation

### Detection
```bash
# Detect drift
terraform plan -refresh-only
```

### Resolution
```bash
# Update state to match reality
terraform refresh

# Or fix drift by applying configuration
terraform apply
```

## State File Corruption

If state file becomes corrupted:

1. Check S3 versioning for previous versions
2. Restore from backup
3. Use `terraform import` to rebuild state
4. Review state file manually (it's JSON)

## Remote State Data Source

Access outputs from other state files:
```hcl
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "terraform-state-devops-platform"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

# Use outputs
resource "aws_instance" "app" {
  subnet_id = data.terraform_remote_state.vpc.outputs.subnet_id
}
```
EOF

# Remote backends guide
cat > docs/terraform/remote-backends.md << 'EOF'
# Terraform Remote Backends

## Backend Types

### Local Backend
Default backend, stores state locally.
```hcl
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

Pros: Simple, no setup required
Cons: No locking, no collaboration, no backup

### S3 Backend
Stores state in S3 bucket with DynamoDB locking.
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

Pros: Reliable, versioning, locking, encryption
Cons: Requires AWS resources, setup overhead

### Terraform Cloud Backend
Managed backend by HashiCorp.
```hcl
terraform {
  backend "remote" {
    organization = "my-org"
    workspaces {
      name = "my-workspace"
    }
  }
}
```

Pros: Managed, built-in VCS integration, policy as code
Cons: Requires Terraform Cloud account, potential cost

### Other Backends

- Consul: Distributed key-value store
- Postgres: Database backend
- Kubernetes: ConfigMap or Secret
- Azure Blob Storage: For Azure environments
- Google Cloud Storage: For GCP environments

## Backend Configuration

### Initialization
```bash
# First time or after backend config change
terraform init

# Migrate from one backend to another
terraform init -migrate-state

# Reconfigure backend
terraform init -reconfigure
```

### Partial Configuration

Define some backend settings in config, others via CLI or environment:
```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    region = "us-east-1"
  }
}
```
```bash
# Provide key via CLI
terraform init -backend-config="key=dev/terraform.tfstate"

# Or via file
terraform init -backend-config=backend-config.hcl
```

## S3 Backend Setup

### Prerequisites

1. S3 bucket for state storage
2. DynamoDB table for locking
3. IAM permissions

### S3 Bucket Requirements
```hcl
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state"
}

# Enable versioning (critical for recovery)
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### DynamoDB Table Requirements
```hcl
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
}
```

Table MUST have:
- Hash key named "LockID"
- Type: String (S)

### IAM Permissions

User/role needs:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": "arn:aws:s3:::my-terraform-state"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::my-terraform-state/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/terraform-locks"
    }
  ]
}
```

## Backend Migration

### Local to Remote
```bash
# 1. Configure remote backend in code
# 2. Run init with migration
terraform init -migrate-state

# Terraform will prompt: "Do you want to copy existing state?"
# Answer: yes

# 3. Verify remote state
terraform state list
```

### Remote to Remote
```bash
# 1. Update backend configuration
# 2. Run init with migration
terraform init -migrate-state

# State automatically copied to new backend
```

### Remote to Local
```bash
# 1. Change backend to local
# 2. Run init with migration
terraform init -migrate-state

# State downloaded from remote to local
```

## Best Practices

1. Use remote backend for production
2. Enable S3 versioning for state recovery
3. Enable encryption at rest and in transit
4. Use separate state files per environment
5. Restrict backend access with IAM
6. Use state locking to prevent conflicts
7. Never manually edit state files
8. Regular state backups
9. Document backend configuration
10. Test state recovery procedures

## Troubleshooting

### Lock Timeout
```bash
# Force unlock (use with caution)
terraform force-unlock LOCK_ID
```

### State Corruption
```bash
# Restore from S3 version
aws s3api list-object-versions --bucket my-state --prefix dev/

# Download specific version
aws s3api get-object --bucket my-state --key dev/terraform.tfstate --version-id VERSION_ID state.tfstate
```

### Backend Access Issues
```bash
# Check AWS credentials
aws sts get-caller-identity

# Check bucket access
aws s3 ls s3://my-terraform-state/

# Check DynamoDB table
aws dynamodb describe-table --table-name terraform-locks
```
