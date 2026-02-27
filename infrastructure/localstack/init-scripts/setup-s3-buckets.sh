#!/bin/bash
# Setup S3 buckets for pipeline artifacts

set -e

ENDPOINT="http://localhost:4566"
PROFILE="localstack"

echo "Setting up S3 buckets for pipeline artifacts..."

# Create artifacts bucket
echo "Creating artifacts bucket..."
aws --endpoint-url=$ENDPOINT --profile $PROFILE \
    s3 mb s3://aws-devops-artifacts || echo "Bucket already exists"

# Create logs bucket
echo "Creating logs bucket..."
aws --endpoint-url=$ENDPOINT --profile $PROFILE \
    s3 mb s3://aws-devops-pipeline-logs || echo "Bucket already exists"

# Enable versioning on artifacts bucket
echo "Enabling versioning on artifacts bucket..."
aws --endpoint-url=$ENDPOINT --profile $PROFILE \
    s3api put-bucket-versioning \
    --bucket aws-devops-artifacts \
    --versioning-configuration Status=Enabled

echo ""
echo "S3 buckets created:"
aws --endpoint-url=$ENDPOINT --profile $PROFILE s3 ls

echo ""
echo "S3 setup complete!"
