#!/bin/bash
# Run Trivy security scan on Docker image

set -e

IMAGE_NAME="${1:-sample-app:latest}"
REPORT_DIR="./security-reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "Running Trivy security scan..."
echo "=============================="
echo "Image: $IMAGE_NAME"
echo ""

# Create reports directory
mkdir -p $REPORT_DIR

# Run Trivy scan
echo "Scanning for vulnerabilities..."
trivy image \
    --severity CRITICAL,HIGH,MEDIUM \
    --format json \
    --output "$REPORT_DIR/trivy-report-$TIMESTAMP.json" \
    $IMAGE_NAME

# Generate human-readable report
echo ""
echo "Generating summary..."
trivy image \
    --severity CRITICAL,HIGH,MEDIUM \
    --format table \
    $IMAGE_NAME | tee "$REPORT_DIR/trivy-summary-$TIMESTAMP.txt"

echo ""
echo "Reports saved:"
echo "  JSON: $REPORT_DIR/trivy-report-$TIMESTAMP.json"
echo "  Summary: $REPORT_DIR/trivy-summary-$TIMESTAMP.txt"
