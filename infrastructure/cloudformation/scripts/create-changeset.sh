#!/bin/bash
set -e

ENDPOINT="http://localhost:4566"
PROFILE="localstack"
STACK_NAME="${1:-parent-stack-dev}"
CHANGESET_NAME="${2:-update-$(date +%s)}"
TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Creating change set for stack updates..."
echo "Stack Name: $STACK_NAME"
echo "Change Set Name: $CHANGESET_NAME"
echo ""

# Create change set
echo "Step 1: Creating change set..."
aws cloudformation create-change-set \
    --stack-name $STACK_NAME \
    --change-set-name $CHANGESET_NAME \
    --template-body file://${TEMPLATE_DIR}/parent/main-stack.yaml \
    --parameters file://${TEMPLATE_DIR}/parent/parent-parameters.json \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE

# Wait for change set creation
echo ""
echo "Step 2: Waiting for change set creation..."
sleep 5

# Describe change set
echo ""
echo "Step 3: Change set details:"
aws cloudformation describe-change-set \
    --stack-name $STACK_NAME \
    --change-set-name $CHANGESET_NAME \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE \
    | jq -r '.Changes[] | "  Action: \(.ResourceChange.Action), Resource: \(.ResourceChange.LogicalResourceId), Type: \(.ResourceChange.ResourceType)"'

echo ""
echo "To execute this change set, run:"
echo "  aws cloudformation execute-change-set \\"
echo "    --stack-name $STACK_NAME \\"
echo "    --change-set-name $CHANGESET_NAME \\"
echo "    --endpoint-url=$ENDPOINT \\"
echo "    --profile $PROFILE"
