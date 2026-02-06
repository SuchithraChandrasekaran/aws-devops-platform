#!/bin/bash

# Day 8: CloudFormation VPC Automation
# Deploys and verifies CloudFormation stack

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "======================================"
echo "Day 8: CloudFormation VPC Deployment"
echo "======================================"
echo ""

# Step 1: Verify LocalStack
echo "Step 1: Verifying LocalStack..."
if ! docker ps | grep -q localstack; then
    echo "ERROR: LocalStack not running"
    exit 1
fi
echo "LocalStack running"
echo ""

# Step 2: Deploy dev stack
echo "Step 2: Deploying dev stack..."
${PROJECT_ROOT}/infrastructure/cloudformation/scripts/deploy-stack.sh dev vpc-stack-dev
echo ""

# Step 3: Verify stack
echo "Step 3: Verifying stack..."
STACK_STATUS=$(aws cloudformation describe-stacks \
    --stack-name vpc-stack-dev \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.Stacks[0].StackStatus')

if [ "$STACK_STATUS" = "CREATE_COMPLETE" ] || [ "$STACK_STATUS" = "UPDATE_COMPLETE" ]; then
    echo "Stack deployed successfully: ${STACK_STATUS}"
else
    echo "ERROR: Stack deployment failed: ${STACK_STATUS}"
    exit 1
fi
echo ""

# Step 4: Display outputs
echo "Step 4: Stack Outputs:"
aws cloudformation describe-stacks \
    --stack-name vpc-stack-dev \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.Stacks[0].Outputs[] | "\(.OutputKey): \(.OutputValue)"'
echo ""

# Step 5: Verify resources
echo "Step 5: Verifying resources..."
VPC_ID=$(aws cloudformation describe-stacks \
    --stack-name vpc-stack-dev \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="VPCId") | .OutputValue')

SUBNET_COUNT=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=${VPC_ID}" \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.Subnets | length')

echo "VPC ID: ${VPC_ID}"
echo "Subnets created: ${SUBNET_COUNT}"

if [ "$SUBNET_COUNT" -eq 2 ]; then
    echo "Infrastructure verified successfully"
else
    echo "ERROR: Expected 2 subnets, found ${SUBNET_COUNT}"
    exit 1
fi

echo ""
echo "======================================"
echo "Day 8 Complete!"
echo "======================================"
