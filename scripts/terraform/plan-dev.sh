#!/bin/bash
set -e

echo "Planning Terraform changes for dev environment..."

cd infrastructure/terraform/environments/dev

terraform plan -out=tfplan

echo ""
echo "Plan saved to tfplan"
echo "Review the plan above before applying"
