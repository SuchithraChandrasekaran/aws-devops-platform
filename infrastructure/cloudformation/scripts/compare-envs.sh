#!/bin/bash

echo "======================================"
echo "Environment Comparison"
echo "======================================"
echo ""

# Dev Stack
echo "DEV Environment:"
echo "----------------"
aws cloudformation describe-stacks \
    --stack-name vpc-multi-env-dev \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.Stacks[0].Outputs[] | "\(.OutputKey): \(.OutputValue)"'

echo ""
echo "----------------"
echo ""

# Prod Stack
echo "PROD Environment:"
echo "----------------"
aws cloudformation describe-stacks \
    --stack-name vpc-multi-env-prod \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.Stacks[0].Outputs[] | "\(.OutputKey): \(.OutputValue)"'

echo ""
echo "======================================"
