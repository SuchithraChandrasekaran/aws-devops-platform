#!/bin/bash
# Download Docker image artifact from S3

set -e

ENDPOINT="http://localhost:4566"
BUCKET="aws-devops-artifacts"
IMAGE_NAME="aws-devops-sample-app"

# Get version (default to latest if not specified)
VERSION=${1:-"latest"}

if [ "$VERSION" == "latest" ]; then
    echo "Finding latest artifact..."
    # List all artifacts and get the latest
    LATEST=$(aws --endpoint-url=$ENDPOINT --profile localstack \
        s3 ls s3://${BUCKET}/docker-images/ | grep ${IMAGE_NAME} | sort | tail -n 1 | awk '{print $4}')
    
    if [ -z "$LATEST" ]; then
        echo "No artifacts found in S3"
        exit 1
    fi
    
    ARTIFACT_PATH="docker-images/${LATEST}"
else
    ARTIFACT_PATH="docker-images/${IMAGE_NAME}-${VERSION}.tar.gz"
fi

echo "Downloading artifact: ${ARTIFACT_PATH}"
aws --endpoint-url=$ENDPOINT --profile localstack \
    s3 cp s3://${BUCKET}/${ARTIFACT_PATH} /tmp/docker-image.tar.gz

echo "Loading Docker image..."
docker load < /tmp/docker-image.tar.gz

echo "Artifact downloaded and loaded!"

# Download metadata
METADATA_FILE=$(echo $ARTIFACT_PATH | sed 's|docker-images/|metadata/|' | sed 's|.tar.gz|.json|')
aws --endpoint-url=$ENDPOINT --profile localstack \
    s3 cp s3://${BUCKET}/${METADATA_FILE} /tmp/artifact-metadata.json 2>/dev/null || true

if [ -f /tmp/artifact-metadata.json ]; then
    echo ""
    echo "📋 Artifact metadata:"
    cat /tmp/artifact-metadata.json | jq '.'
fi

# Cleanup
rm -f /tmp/docker-image.tar.gz