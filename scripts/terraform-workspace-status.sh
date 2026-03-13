#!/bin/bash

TERRAFORM_DIR="$HOME/aws-devops-platform/infrastructure/terraform/aws-free-tier"

cd $TERRAFORM_DIR

echo "=== Terraform Workspace Status ==="
echo "Current workspace: $(terraform workspace show)"
echo ""
echo "All workspaces:"
terraform workspace list
echo ""
echo "Resources in current workspace:"
terraform state list 2>/dev/null || echo "No resources in state"
