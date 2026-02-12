#!/bin/bash

echo "========================================"
echo "Terraform Drift Detection - Day 14"
echo "Date: $(date)"
echo "========================================"
echo ""

cd ~/aws-devops-platform/infrastructure/terraform/environments/dev

echo "Checking for infrastructure drift..."
echo ""

if terraform plan -detailed-exitcode -no-color > /tmp/drift-check.txt 2>&1; then
    echo "✓ NO DRIFT DETECTED"
    echo "Infrastructure matches Terraform configuration"
    exit 0
else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 2 ]; then
        echo "✗ DRIFT DETECTED"
        echo ""
        echo "Resources with drift:"
        grep "will be updated\|will be created\|will be destroyed" /tmp/drift-check.txt
        echo ""
        echo "Run 'terraform apply' to fix drift"
        exit 2
    else
        echo "✗ ERROR running terraform plan"
        cat /tmp/drift-check.txt
        exit 1
    fi
fi
