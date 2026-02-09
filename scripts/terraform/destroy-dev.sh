#!/bin/bash
set -e

echo "Destroying Terraform resources for dev environment..."

cd infrastructure/terraform/environments/dev

terraform destroy -auto-approve

echo "Terraform resources destroyed"
