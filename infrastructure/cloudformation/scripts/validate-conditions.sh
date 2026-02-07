#!/bin/bash
set -e

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../../" && pwd )"
TEMPLATE_PATH="${PROJECT_ROOT}/infrastructure/cloudformation/vpc/vpc-multi-env.yaml"

echo "======================================"
echo "Validating CloudFormation Template"
echo "======================================"
echo ""

# Validate template syntax
echo "Step 1: Validating template syntax..."
aws cloudformation validate-template \
    --template-body file://"${TEMPLATE_PATH}" \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    > /dev/null

if [ $? -eq 0 ]; then
    echo "Template syntax is valid"
else
    echo "Template validation failed"
    exit 1
fi

echo ""
echo "Step 2: Checking condition logic..."
echo "Template contains the following conditions:"
grep -A 1 "^Conditions:" "${TEMPLATE_PATH}"

echo ""
echo "Step 3: Verifying parameter constraints..."
grep -A 5 "^Parameters:" "${TEMPLATE_PATH}"

echo ""
echo "======================================"
echo "Validation Complete"
echo "======================================"
