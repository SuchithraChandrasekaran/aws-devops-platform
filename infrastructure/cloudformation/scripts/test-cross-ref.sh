#!/bin/bash
set -e

ENDPOINT="http://localhost:4566"
PROFILE="localstack"
STACK_NAME="${1:-parent-stack-dev}"

echo "Testing cross-stack references..."
echo "Parent Stack: $STACK_NAME"
echo ""

# Get parent stack outputs
echo "Parent Stack Outputs:"
aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE \
    | jq -r '.Stacks[0].Outputs[] | "  \(.OutputKey): \(.OutputValue)"'

echo ""

# Get nested stack names
NESTED_STACKS=$(aws cloudformation describe-stack-resources \
    --stack-name $STACK_NAME \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE \
    | jq -r '.StackResources[] | select(.ResourceType == "AWS::CloudFormation::Stack") | .PhysicalResourceId')

# Show nested stack outputs
for nested in $NESTED_STACKS; do
    echo "Nested Stack: $nested"
    aws cloudformation describe-stacks \
        --stack-name $nested \
        --endpoint-url=$ENDPOINT \
        --profile $PROFILE \
        | jq -r '.Stacks[0].Outputs[] | "  \(.OutputKey): \(.OutputValue)"'
    echo ""
done

# Test export/import
echo "Testing Exports:"
aws cloudformation list-exports \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE \
    | jq -r '.Exports[] | select(.Name | contains("'$STACK_NAME'")) | "  \(.Name): \(.Value)"'

echo ""
echo "Cross-stack reference test completed!"
