# Days 41 to 43 Command Recall

---

## Day 41 - Setup CodePipeline with GitHub Actions

# buildspec.yml for CodeBuild
cat << 'BUILDSPEC' > buildspec.yml
version: 0.2
phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws ecr get-login-password | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
  build:
    commands:
      - docker build -t my-app:latest .
      - docker tag my-app:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
  post_build:
    commands:
      - docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
BUILDSPEC
```

---

## Day 42 - End-to-end testing and validation of AWS deployment. Cost audit

```bash
# --- End-to-end validation ---

# 1. Verify EC2 is running and reachable
aws ec2 describe-instances \
  --filters Name=tag:Name,Values=myapp-server \
  --query 'Reservations[].Instances[].{ID:InstanceId,IP:PublicIpAddress,State:State.Name}'

curl -f http://<ec2-public-ip> && echo "App OK"

# 2. Verify RDS is accessible from EC2
ssh -i <key.pem> ec2-user@<ec2-ip> \
  "psql -h <rds-endpoint> -U admin -d postgres -c 'SELECT 1'"

# 3. Verify NGINX reverse proxy
curl -I http://<ec2-public-ip>

# 4. Verify CloudWatch metrics flowing
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=<instance-id> \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 --statistics Average

# 5. Verify all alarms healthy
aws cloudwatch describe-alarms \
  --query 'MetricAlarms[].{Name:AlarmName,State:StateValue}'

# 6. Verify SSM parameters accessible
aws ssm get-parameters-by-path --path "/myapp/prod" --with-decryption

# --- Cost audit ---
# Check current month estimated charges
aws cloudwatch get-metric-statistics \
  --namespace AWS/Billing \
  --metric-name EstimatedCharges \
  --dimensions Name=Currency,Value=USD \
  --start-time $(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 86400 --statistics Maximum

# Cost Explorer - breakdown by service
aws ce get-cost-and-usage \
  --time-period Start=$(date -u -d '30 days ago' +%Y-%m-%d),End=$(date -u +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE

# List all running resources (cost check)
echo "=== EC2 ===" && aws ec2 describe-instances \
  --filters Name=instance-state-name,Values=running \
  --query 'Reservations[].Instances[].{ID:InstanceId,Type:InstanceType}'

echo "=== RDS ===" && aws rds describe-db-instances \
  --query 'DBInstances[].{ID:DBInstanceIdentifier,Class:DBInstanceClass,Status:DBInstanceStatus}'

echo "=== S3 ===" && aws s3 ls

# STOP RDS if not needed
aws rds stop-db-instance --db-instance-identifier myapp-db
```

---

## Day 43 - Multi-environment Terraform workspaces

```bash
# Init Terraform
terraform init

# List workspaces (default only at start)
terraform workspace list

# Create dev workspace
terraform workspace new dev

# Create prod workspace
terraform workspace new prod

# Switch to dev
terraform workspace select dev

# Check current workspace
terraform workspace show
```

```hcl
# variables.tf - environment-aware config
variable "env_config" {
  default = {
    dev = {
      instance_type = "t2.micro"
      db_class      = "db.t2.micro"
      min_size      = 1
      max_size      = 2
    }
    prod = {
      instance_type = "t3.small"
      db_class      = "db.t3.small"
      min_size      = 2
      max_size      = 5
    }
  }
}

locals {
  env    = terraform.workspace
  config = var.env_config[local.env]
}
```

```hcl
# main.tf - uses workspace locals
resource "aws_instance" "app" {
  instance_type = local.config.instance_type
  ami           = "ami-0c02fb55956c7d316"
  tags = {
    Name        = "${local.env}-myapp-server"
    Environment = local.env
  }
}

resource "aws_db_instance" "db" {
  identifier        = "${local.env}-myapp-db"
  instance_class    = local.config.db_class
  engine            = "postgres"
  allocated_storage = 20
}
```

```hcl
# backend.tf - separate state per workspace
terraform {
  backend "s3" {
    bucket         = "tf-state-bucket"
    key            = "env/${terraform.workspace}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-lock"
    encrypt        = true
  }
}
```

```bash
# Deploy to dev
terraform workspace select dev
terraform plan
terraform apply -auto-approve

# Deploy to prod
terraform workspace select prod
terraform plan
terraform apply -auto-approve

# Compare state between workspaces
terraform workspace select dev && terraform show
terraform workspace select prod && terraform show

# Destroy dev only (keeps prod safe)
terraform workspace select dev
terraform destroy -auto-approve
```

---
