#!/bin/bash
# Build Docker image and push to S3 as artifact

set -e

ENDPOINT="http://localhost:4566"
BUCKET="aws-devops-artifacts"
IMAGE_NAME="aws-devops-sample-app"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
GIT_SHA=$(git rev-parse --short HEAD)
VERSION="${TIMESTAMP}-${GIT_SHA}"

echo "Building Docker image..."
cd ~/aws-devops-platform/applications/sample-app

# Build the image
docker build -t ${IMAGE_NAME}:${VERSION} .
docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest

echo "Saving Docker image..."
docker save ${IMAGE_NAME}:${VERSION} | gzip > /tmp/${IMAGE_NAME}-${VERSION}.tar.gz

echo "☁️  Uploading to S3..."
aws --endpoint-url=$ENDPOINT --profile localstack \
    s3 cp /tmp/${IMAGE_NAME}-${VERSION}.tar.gz \
    s3://${BUCKET}/docker-images/${IMAGE_NAME}-${VERSION}.tar.gz

# Upload metadata
cat > /tmp/artifact-metadata.json <<EOF
{
  "image_name": "${IMAGE_NAME}",
  "version": "${VERSION}",
  "git_sha": "${GIT_SHA}",
  "timestamp": "${TIMESTAMP}",
  "build_date": "$(date -Iseconds)",
  "size_bytes": $(stat -f%z /tmp/${IMAGE_NAME}-${VERSION}.tar.gz 2>/dev/null || stat -c%s /tmp/${IMAGE_NAME}-${VERSION}.tar.gz)
}
EOF

aws --endpoint-url=$ENDPOINT --profile localstack \
    s3 cp /tmp/artifact-metadata.json \
    s3://${BUCKET}/metadata/${IMAGE_NAME}-${VERSION}.json

echo "Artifact uploaded successfully!"
echo "   Version: ${VERSION}"
echo "   Location: s3://${BUCKET}/docker-images/${IMAGE_NAME}-${VERSION}.tar.gz"

# Cleanup
rm -f /tmp/${IMAGE_NAME}-${VERSION}.tar.gz /tmp/artifact-metadata.json