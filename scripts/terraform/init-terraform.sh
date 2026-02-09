#!/bin/bash
set -e

echo "Initializing Terraform for dev environment..."

cd infrastructure/terraform/environments/dev

# Copy provider config
cp ../../provider.tf .

# Initialize Terraform
terraform init

echo "Terraform initialized successfully"
echo "State file: terraform-dev.tfstate"
