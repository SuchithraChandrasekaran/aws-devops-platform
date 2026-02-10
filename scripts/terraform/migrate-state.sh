#!/bin/bash
set -e

echo "=== Migrating Terraform State to Remote Backend ==="
echo ""

cd ~/aws-devops-platform/infrastructure/terraform/environments/dev

echo "Step 1: Current state (local)..."
terraform state list

echo ""
echo "Step 2: Re-initializing with remote backend..."
echo "Terraform will ask if you want to copy existing state to the new backend."
echo "Answer 'yes' when prompted."
echo ""

# This will prompt for migration
terraform init -migrate-state

echo ""
echo "Step 3: Verifying remote state..."
terraform state list

echo ""
echo "Step 4: Checking S3 bucket for state file..."
aws s3 ls s3://terraform-state-devops-platform/dev/ \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    --recursive

echo ""
echo "=== State Migration Complete ==="
echo ""
echo "State file is now stored remotely in S3"
echo "DynamoDB provides state locking for concurrent operations"
