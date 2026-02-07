#!/bin/bash
set -e

ENDPOINT="http://localhost:4566"
PROFILE="localstack"
STACK_NAME="${1:-parent-stack-dev}"
TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Deploying nested stack architecture..."
echo "Stack Name: $STACK_NAME"
echo "Template Directory: $TEMPLATE_DIR"

# Validate parent template
echo ""
echo "Step 1: Validating parent template..."
aws cloudformation validate-template \
    --template-body file://${TEMPLATE_DIR}/parent/main-stack.yaml \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE

# Validate nested templates
echo ""
echo "Step 2: Validating nested templates..."
aws cloudformation validate-template \
    --template-body file://${TEMPLATE_DIR}/vpc/vpc-multi-env.yaml \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE

aws cloudformation validate-template \
    --template-body file://${TEMPLATE_DIR}/database/rds-nested.yaml \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE

# Deploy parent stack (which deploys nested stacks)
echo ""
echo "Step 3: Deploying parent stack with nested stacks..."
aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-body file://${TEMPLATE_DIR}/parent/main-stack.yaml \
    --parameters file://${TEMPLATE_DIR}/parent/parent-parameters.json \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE

# Wait for stack creation
echo ""
echo "Step 4: Waiting for stack creation..."
aws cloudformation wait stack-create-complete \
    --stack-name $STACK_NAME \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE

# Show stack outputs
echo ""
echo "Step 5: Stack outputs:"
aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE \
    | jq -r '.Stacks[0].Outputs'

# List nested stacks
echo ""
echo "Step 6: Nested stacks:"
aws cloudformation list-stacks \
    --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE \
    | jq -r '.StackSummaries[] | select(.StackName | contains("'$STACK_NAME'")) | .StackName'

echo ""
echo "Deployment completed successfully!"
