#!/bin/bash
set -e

echo "=== Day 11/95 - Terraform Deployment Automation ==="
echo ""

cd ~/aws-devops-platform

# Initialize Terraform
echo "Step 1: Initializing Terraform..."
./scripts/terraform/init-terraform.sh

# Plan changes
echo ""
echo "Step 2: Planning Terraform changes..."
./scripts/terraform/plan-dev.sh

# Apply changes
echo ""
echo "Step 3: Applying Terraform configuration..."
./scripts/terraform/apply-dev.sh

# Compare outputs
echo ""
echo "Step 4: Comparing CloudFormation vs Terraform..."
./scripts/terraform/compare-outputs.sh

echo ""
echo "=== Day 11 Automation Complete ==="
echo "Review the Terraform outputs and compare with CloudFormation"
