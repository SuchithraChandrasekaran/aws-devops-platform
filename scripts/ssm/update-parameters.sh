#!/bin/bash
set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <parameter-name> <new-value>"
    echo "Example: $0 /dev/devops-platform/app/version 1.1.0"
    exit 1
fi

PARAM_NAME="$1"
NEW_VALUE="$2"

echo "Updating: $PARAM_NAME"
echo "New value: $NEW_VALUE"

aws ssm put-parameter \
    --name "$PARAM_NAME" \
    --value "$NEW_VALUE" \
    --overwrite \
    --endpoint-url=http://localhost:4566 \
    --profile localstack

echo ""
echo "Updated successfully!"

aws ssm get-parameter \
    --name "$PARAM_NAME" \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    --query 'Parameter.{Name:Name,Value:Value,Version:Version}' \
    --output table
