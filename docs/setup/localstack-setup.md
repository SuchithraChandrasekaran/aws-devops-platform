# LocalStack Setup Guide

## Overview

LocalStack is a fully functional local AWS cloud stack that allows you to develop and test your cloud and serverless applications offline. This guide covers the setup and usage of LocalStack for the AWS DevOps Platform project.

---

## What is LocalStack?

LocalStack provides an easy-to-use test/mocking framework for developing Cloud applications. It spins up a testing environment on your local machine that provides the same functionality and APIs as the real AWS cloud environment.

### Supported Services (used in this project)

- **EC2** - Elastic Compute Cloud (virtual servers)
- **S3** - Simple Storage Service
- **DynamoDB** - NoSQL database
- **Lambda** - Serverless functions
- **CloudFormation** - Infrastructure as Code
- **CloudWatch** - Monitoring and logging
- **IAM** - Identity and Access Management
- **SNS** - Simple Notification Service
- **SQS** - Simple Queue Service

---

## Installation

### Option 1: Using Docker (Recommended)

LocalStack is already configured via Docker Compose in this project:

```bash
cd ~/aws-devops-platform/infrastructure/localstack
docker-compose up -d
```

### Option 2: Using pip

```bash
pip install localstack --break-system-packages
localstack start
```

### Verify Installation

```bash
# Check if LocalStack is running
curl http://localhost:4566/_localstack/health

# Expected response: JSON with service statuses
```

---

## Configuration

### Docker Compose Configuration

Located at: `infrastructure/localstack/docker-compose.yml`

Key configuration options:

```yaml
services:
  localstack:
    image: localstack/localstack:latest
    ports:
      - "4566:4566"  # Gateway port
    environment:
      - SERVICES=ec2,s3,dynamodb,lambda,cloudformation,cloudwatch,sns,sqs,iam
      - DEBUG=1
      - DATA_DIR=/tmp/localstack/data
      - PERSISTENCE=1  # Data persists between restarts
```

### AWS CLI Configuration for LocalStack

Configure a dedicated AWS profile for LocalStack:

```bash
aws configure --profile localstack
# AWS Access Key ID: test
# AWS Secret Access Key: test
# Default region name: us-east-1
# Default output format: json
```

### Using the LocalStack Profile

```bash
# Standard AWS CLI command with LocalStack
aws --endpoint-url=http://localhost:4566 \
    --profile localstack \
    ec2 describe-instances
```

---

## Directory Structure

```
infrastructure/localstack/
├── docker-compose.yml          # LocalStack container configuration
├── init-scripts/               # Initialization scripts
│   └── setup-ec2.sh           # EC2 instance setup
└── README.md                   # This file
```

---

## Usage Guide

### Starting LocalStack

```bash
# Navigate to LocalStack directory
cd ~/aws-devops-platform/infrastructure/localstack

# Start LocalStack
docker-compose up -d

# View logs
docker-compose logs -f

# Check health
curl http://localhost:4566/_localstack/health
```

### Stopping LocalStack

```bash
# Stop LocalStack (preserves data)
docker-compose stop

# Stop and remove (loses data unless PERSISTENCE=1)
docker-compose down

# Remove all data
docker-compose down -v
```

### Creating EC2 Instance

Use the provided script:

```bash
cd ~/aws-devops-platform/infrastructure/localstack/init-scripts
chmod +x setup-ec2.sh
./setup-ec2.sh
```

Or manually:

```bash
# Create key pair
aws --endpoint-url=http://localhost:4566 \
    ec2 create-key-pair \
    --key-name aws-devops-key \
    --query 'KeyMaterial' \
    --output text > aws-devops-key.pem

chmod 400 aws-devops-key.pem

# Create security group
aws --endpoint-url=http://localhost:4566 \
    ec2 create-security-group \
    --group-name aws-devops-sg \
    --description "Security group for sample app"

# Launch instance
aws --endpoint-url=http://localhost:4566 \
    ec2 run-instances \
    --image-id ami-0c55b159cbfafe1f0 \
    --instance-type t2.micro \
    --key-name aws-devops-key \
    --security-groups aws-devops-sg
```

---

## Common Commands

### EC2 Operations

```bash
# List all instances
aws --endpoint-url=http://localhost:4566 \
    ec2 describe-instances --profile localstack

# List running instances only
aws --endpoint-url=http://localhost:4566 \
    ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --profile localstack

# Terminate instance
aws --endpoint-url=http://localhost:4566 \
    ec2 terminate-instances \
    --instance-ids i-1234567890abcdef0 \
    --profile localstack

# Create tags
aws --endpoint-url=http://localhost:4566 \
    ec2 create-tags \
    --resources i-1234567890abcdef0 \
    --tags Key=Name,Value=my-instance \
    --profile localstack
```

### S3 Operations

```bash
# Create bucket
aws --endpoint-url=http://localhost:4566 \
    s3 mb s3://my-bucket --profile localstack

# List buckets
aws --endpoint-url=http://localhost:4566 \
    s3 ls --profile localstack

# Upload file
aws --endpoint-url=http://localhost:4566 \
    s3 cp myfile.txt s3://my-bucket/ --profile localstack
```

### DynamoDB Operations

```bash
# Create table
aws --endpoint-url=http://localhost:4566 \
    dynamodb create-table \
    --table-name MyTable \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --profile localstack

# List tables
aws --endpoint-url=http://localhost:4566 \
    dynamodb list-tables --profile localstack
```

---

## Troubleshooting

### Port 4566 Already in Use

```bash
# Find process using port 4566
sudo lsof -i :4566

# Kill the process
sudo kill -9 <PID>

# Restart LocalStack
docker-compose restart
```

### Container Won't Start

```bash
# View container logs
docker-compose logs localstack

# Remove and restart
docker-compose down
docker-compose up -d
```

### AWS CLI Can't Connect

```bash
# Verify LocalStack is running
curl http://localhost:4566/_localstack/health

# Check profile configuration
cat ~/.aws/config
cat ~/.aws/credentials

# Test with explicit endpoint
aws --endpoint-url=http://localhost:4566 \
    ec2 describe-instances
```

### Data Not Persisting

Ensure `PERSISTENCE=1` is set in docker-compose.yml:

```yaml
environment:
  - PERSISTENCE=1
  - DATA_DIR=/tmp/localstack/data
```

---

## Best Practices

### 1. Use Dedicated Profile

Always use the `--profile localstack` flag to avoid accidentally running commands against real AWS.

### 2. Create Helper Aliases

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias awslocal='aws --endpoint-url=http://localhost:4566 --profile localstack'
```

Then use:

```bash
awslocal ec2 describe-instances
```

### 3. Clean Up Resources

Regularly clean up unused resources:

```bash
# Terminate all instances
awslocal ec2 terminate-instances \
    --instance-ids $(awslocal ec2 describe-instances \
    --query 'Reservations[*].Instances[*].InstanceId' \
    --output text)
```

### 4. Use Init Scripts

Place initialization scripts in `init-scripts/` directory. LocalStack will automatically execute them on startup.

### 5. Enable Persistence

For development work that spans multiple sessions, enable persistence to keep your data between restarts.

---

## Integration with CI/CD

### GitHub Actions Integration

LocalStack can be used in GitHub Actions:

```yaml
- name: Start LocalStack
  run: |
    pip install localstack
    docker pull localstack/localstack
    docker run -d --name localstack -p 4566:4566 localstack/localstack

- name: Wait for LocalStack
  run: |
    for i in {1..30}; do
      curl -s http://localhost:4566/_localstack/health && break
      sleep 2
    done
```

---

## Differences from Real AWS

### What Works the Same

- API compatibility (same AWS CLI commands)
- Service interactions
- IAM policies (basic)
- CloudFormation templates

### Limitations

- No actual SSH access to EC2 instances
- Some advanced features may not be supported
- Performance differs from real AWS
- Some service integrations may be simplified

---

## Day 4 Checklist

- [x] Install LocalStack
- [x] Configure docker-compose.yml
- [x] Create AWS CLI profile
- [x] Start LocalStack container
- [x] Create EC2 instance
- [x] Deploy application
- [x] Run health checks
- [x] Document setup process

---

