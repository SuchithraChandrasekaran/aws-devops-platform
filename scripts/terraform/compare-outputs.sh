#!/bin/bash
set -e

echo "Comparing CloudFormation vs Terraform outputs..."

echo ""
echo "CloudFormation VPC (from Day 9):"
aws cloudformation describe-stacks \
    --stack-name vpc-multi-env-dev \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.Stacks[0].Outputs[] | "\(.OutputKey): \(.OutputValue)"'

echo ""
echo "Terraform VPC (Day 11):"
cd infrastructure/terraform/environments/dev
terraform output -json | jq -r 'to_entries[] | "\(.key): \(.value.value)"'

echo ""
echo "Both VPCs should have similar structure but different IDs"
