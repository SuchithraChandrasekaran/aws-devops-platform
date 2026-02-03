#!/bin/bash
# Cleanup old artifacts from S3

set -e

ENDPOINT="http://localhost:4566"
BUCKET="aws-devops-artifacts"
IMAGE_NAME="aws-devops-sample-app"
KEEP_LAST=5  # Keep last 5 artifacts

echo "Cleaning up old artifacts..."

# List all artifacts
ARTIFACTS=$(aws --endpoint-url=$ENDPOINT --profile localstack \
    s3 ls s3://${BUCKET}/docker-images/ | grep ${IMAGE_NAME} | sort -r)

# Count artifacts
TOTAL=$(echo "$ARTIFACTS" | wc -l)

if [ $TOTAL -le $KEEP_LAST ]; then
    echo "Only ${TOTAL} artifacts found. Nothing to clean up."
    exit 0
fi

echo "Found ${TOTAL} artifacts. Keeping last ${KEEP_LAST}..."

# Delete old artifacts
echo "$ARTIFACTS" | tail -n +$((KEEP_LAST + 1)) | while read -r line; do
    FILE=$(echo $line | awk '{print $4}')
    echo "  Deleting: ${FILE}"
    aws --endpoint-url=$ENDPOINT --profile localstack \
        s3 rm s3://${BUCKET}/docker-images/${FILE}
    
    # Also delete metadata
    METADATA=$(echo $FILE | sed 's|.tar.gz|.json|')
    aws --endpoint-url=$ENDPOINT --profile localstack \
        s3 rm s3://${BUCKET}/metadata/${METADATA} 2>/dev/null || true
done

echo "Cleanup complete!"