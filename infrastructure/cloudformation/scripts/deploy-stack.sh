#!/bin/bash

## Deploy CloudFormation stack to LocalStack
## Usage: ./deploy-stack.sh <environment> <stack-name>

set -e

ENVIRONMENT=${1:-dev}
STACK_NAME=${2:-vpc-stack-${ENVIRONMENT}}

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TEMPLATE_FILE="${PROJECT_ROOT}/infrastructure/cloudformation/vpc/vpc-main.yaml"
PARAMETERS_FILE="${PROJECT_ROOT}/infrastructure/cloudformation/vpc/parameters-${ENVIRONMENT}.json"

echo "======================================"
echo "Deploying CloudFormation Stack"
echo "======================================"
echo "Stack Name: ${STACK_NAME}"
echo "Environment: ${ENVIRONMENT}"
echo "Template: ${TEMPLATE_FILE}"
echo "Parameters: ${PARAMETERS_FILE}"
echo ""

# Check if stack exists
STACK_EXISTS=$(aws cloudformation describe-stacks \
    --stack-name ${STACK_NAME} \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    2>/dev/null | jq -r '.Stacks[0].StackName' || echo "")

if [ -z "$STACK_EXISTS" ]; then
    echo "Creating new stack..."
    aws cloudformation create-stack \
        --stack-name ${STACK_NAME} \
        --template-body file://${TEMPLATE_FILE} \
        --parameters file://${PARAMETERS_FILE} \
        --endpoint-url=http://localhost:4566 \
        --profile localstack
    
    echo "Waiting for stack creation to complete..."
    aws cloudformation wait stack-create-complete \
        --stack-name ${STACK_NAME} \
        --endpoint-url=http://localhost:4566 \
        --profile localstack \
        2>/dev/null || true
else
    echo "Stack exists, updating..."
    aws cloudformation update-stack \
        --stack-name ${STACK_NAME} \
        --template-body file://${TEMPLATE_FILE} \
        --parameters file://${PARAMETERS_FILE} \
        --endpoint-url=http://localhost:4566 \
        --profile localstack \
        2>/dev/null || echo "No updates needed"
fi

echo ""
echo "Stack deployment complete!"
echo "Stack Name: ${STACK_NAME}"

# Show stack outputs
echo ""
echo "Stack Outputs:"
aws cloudformation describe-stacks \
    --stack-name ${STACK_NAME} \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.Stacks[0].Outputs'
