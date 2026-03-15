#!/bin/bash

# bucket-status.sh
# Shows S3 bucket configuration and object summary
# Usage: bash bucket-status.sh <bucket-name>

set -e

BUCKET=$1

if [ -z "$BUCKET" ]; then
  echo "Usage: bash bucket-status.sh <bucket-name>"
  exit 1
fi

echo "=== S3 Bucket Status: $BUCKET ==="

echo ""
echo "--- Versioning ---"
aws s3api get-bucket-versioning --bucket $BUCKET

echo ""
echo "--- Encryption ---"
aws s3api get-bucket-encryption \
  --bucket $BUCKET \
  --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' \
  --output text

echo ""
echo "--- Lifecycle Rules ---"
aws s3api get-bucket-lifecycle-configuration \
  --bucket $BUCKET \
  --query 'Rules[*].[ID,Status]' \
  --output table 2>/dev/null || echo "No lifecycle rules"

echo ""
echo "--- Object Count ---"
aws s3api list-objects-v2 \
  --bucket $BUCKET \
  --query 'KeyCount' \
  --output text

echo ""
echo "--- All Objects ---"
aws s3 ls s3://$BUCKET --recursive

echo "=== Status Complete ==="
