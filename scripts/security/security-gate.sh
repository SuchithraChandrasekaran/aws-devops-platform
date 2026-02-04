#!/bin/bash
# Security gate check - fail if critical vulnerabilities found

set -e

IMAGE_NAME="${1:-sample-app:latest}"
MAX_CRITICAL=0
MAX_HIGH=5

echo "Running security gate check..."
echo "=============================="

# Run Trivy scan
SCAN_OUTPUT=$(trivy image \
    --severity CRITICAL,HIGH \
    --format json \
    --quiet \
    $IMAGE_NAME)

# Count vulnerabilities
CRITICAL=$(echo "$SCAN_OUTPUT" | grep -o '"Severity":"CRITICAL"' | wc -l)
HIGH=$(echo "$SCAN_OUTPUT" | grep -o '"Severity":"HIGH"' | wc -l)

echo "Vulnerability Count:"
echo "  CRITICAL: $CRITICAL (max allowed: $MAX_CRITICAL)"
echo "  HIGH: $HIGH (max allowed: $MAX_HIGH)"
echo ""

FAIL=0
if [ $CRITICAL -gt $MAX_CRITICAL ]; then
    echo "FAIL: Too many CRITICAL vulnerabilities ($CRITICAL > $MAX_CRITICAL)"
    FAIL=1
fi

if [ $HIGH -gt $MAX_HIGH ]; then
    echo "FAIL: Too many HIGH vulnerabilities ($HIGH > $MAX_HIGH)"
    FAIL=1
fi

if [ $FAIL -eq 0 ]; then
    echo "PASS: Security gate check passed!"
    exit 0
else
    echo "FAIL: Security gate check failed!"
    exit 1
fi
