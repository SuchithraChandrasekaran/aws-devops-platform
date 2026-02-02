#!/bin/bash
# Check pipeline status and list artifacts

set -e

ENDPOINT="http://localhost:4566"
BUCKET="aws-devops-artifacts"
IMAGE_NAME="aws-devops-sample-app"

echo "Pipeline Status Report"
echo "========================="
echo ""

# Check S3 bucket
echo "S3 Bucket Status:"
aws --endpoint-url=$ENDPOINT --profile localstack \
    s3 ls s3://${BUCKET} --recursive | grep docker-images | tail -5

echo ""
echo "Recent Artifacts:"
aws --endpoint-url=$ENDPOINT --profile localstack \
    s3 ls s3://${BUCKET}/docker-images/ | grep ${IMAGE_NAME} | sort -r | head -5

echo ""
echo "Local Docker Images:"
docker images | grep ${IMAGE_NAME}

echo ""
echo "Pipeline Status: OK"