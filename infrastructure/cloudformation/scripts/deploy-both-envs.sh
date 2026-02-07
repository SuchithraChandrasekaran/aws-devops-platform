#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "${SCRIPT_DIR}/../../.." && pwd )"
TEMPLATE_PATH="${PROJECT_ROOT}/infrastructure/cloudformation/vpc/vpc-multi-env.yaml"

echo "======================================"
echo "Deploying Both Environments"
echo "======================================"

# Verify LocalStack is running
if ! docker ps | grep -q localstack; then
    echo "ERROR: LocalStack is not running"
    echo "Start it with: docker start localstack"
    exit 1
fi

# Deploy Dev
echo ""
echo "Deploying Dev Environment..."
aws cloudformation deploy \
    --template-file "${TEMPLATE_PATH}" \
    --stack-name vpc-multi-env-dev \
    --parameter-overrides file://"${PROJECT_ROOT}/infrastructure/cloudformation/vpc/parameters-dev.json" \
    --capabilities CAPABILITY_IAM \
    --endpoint-url=http://localhost:4566 \
    --profile localstack

echo "Dev deployment complete"

# Deploy Prod
echo ""
echo "Deploying Prod Environment..."
aws cloudformation deploy \
    --template-file "${TEMPLATE_PATH}" \
    --stack-name vpc-multi-env-prod \
    --parameter-overrides file://"${PROJECT_ROOT}/infrastructure/cloudformation/vpc/parameters-prod.json" \
    --capabilities CAPABILITY_IAM \
    --endpoint-url=http://localhost:4566 \
    --profile localstack

echo "Prod deployment complete"
echo ""
echo "======================================"
echo "Both Environments Deployed"
echo "======================================"
