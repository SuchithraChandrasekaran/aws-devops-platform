#!/bin/bash
set -e

PATH_PREFIX="${1:-/dev/devops-platform}"

echo "=== Parameters under: $PATH_PREFIX ==="
echo ""

aws ssm get-parameters-by-path \
    --path "$PATH_PREFIX" \
    --recursive \
    --with-decryption \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    --output table

echo ""
echo "Total count:"
aws ssm get-parameters-by-path \
    --path "$PATH_PREFIX" \
    --recursive \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    --query 'Parameters[*].Name' \
    --output json | jq '. | length'
