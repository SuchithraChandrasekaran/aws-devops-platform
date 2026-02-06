#!/bin/bash

# Describe CloudFormation stack
# Usage: ./describe-stack.sh <stack-name>

STACK_NAME=${1:-vpc-stack-dev}

echo "Stack Information: ${STACK_NAME}"
echo "======================================"

aws cloudformation describe-stacks \
    --stack-name ${STACK_NAME} \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.Stacks[0]'
