#!/bin/bash
set -e

echo "Applying Terraform configuration for dev environment..."

cd infrastructure/terraform/environments/dev

if [ -f tfplan ]; then
    terraform apply tfplan
    rm tfplan
else
    echo "No plan file found. Run plan-dev.sh first"
    exit 1
fi

echo ""
echo "Terraform apply complete"
echo "Showing outputs:"
terraform output
