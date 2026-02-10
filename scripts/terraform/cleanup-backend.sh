#!/bin/bash
set -e

echo "=== Cleaning up Terraform Backend Resources ==="
echo ""
echo "WARNING: This will destroy S3 bucket and DynamoDB table"
echo "Make sure all environments have migrated away from remote backend first"
echo ""
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled"
    exit 0
fi

cd ~/aws-devops-platform/infrastructure/terraform/backend

echo "Step 1: Destroying backend infrastructure..."
terraform destroy -auto-approve

echo ""
echo "Step 2: Verifying resources deleted..."

# Check S3
aws s3 ls \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | grep terraform-state-devops-platform || echo "S3 bucket deleted"

# Check DynamoDB
aws dynamodb list-tables \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.TableNames[]' | grep terraform-state-locks || echo "DynamoDB table deleted"

echo ""
echo "=== Backend Cleanup Complete ==="
