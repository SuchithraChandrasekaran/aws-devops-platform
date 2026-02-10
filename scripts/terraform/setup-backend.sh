#!/bin/bash
set -e

echo "=== Setting up Terraform Remote Backend ==="
echo ""

cd ~/aws-devops-platform/infrastructure/terraform/backend

# Copy provider configuration
cp ../provider.tf .

echo "Step 1: Initializing backend infrastructure..."
terraform init

echo ""
echo "Step 2: Planning backend resources..."
terraform plan -out=backend.tfplan

echo ""
echo "Step 3: Creating S3 bucket and DynamoDB table..."
terraform apply backend.tfplan
rm backend.tfplan

echo ""
echo "Step 4: Verifying backend resources..."
terraform output

echo ""
echo "=== Backend Setup Complete ==="
echo ""
echo "S3 Bucket: $(terraform output -raw s3_bucket_name)"
echo "DynamoDB Table: $(terraform output -raw dynamodb_table_name)"
echo ""
echo "Next: Run migrate-state.sh to migrate dev environment to remote backend"
