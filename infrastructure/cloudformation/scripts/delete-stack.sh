#!/bin/bash

# Delete CloudFormation stack
# Usage: ./delete-stack.sh <stack-name>

STACK_NAME=${1:-vpc-stack-dev}

echo "Deleting stack: ${STACK_NAME}"

aws cloudformation delete-stack \
    --stack-name ${STACK_NAME} \
    --endpoint-url=http://localhost:4566 \
    --profile localstack

echo "Stack deletion initiated"
