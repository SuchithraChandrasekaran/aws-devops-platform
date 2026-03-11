#!/bin/bash

# smoke-test.sh
# Run after deployment to confirm app is responding
# Usage: bash smoke-test.sh <host>

set -e

HOST=$1

if [ -z "$HOST" ]; then
  echo "Usage: bash smoke-test.sh <host>"
  exit 1
fi

echo "=== Smoke Test Started ==="
echo "Host: $HOST"

# Check health endpoint
echo "Checking /health..."
HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$HOST/health)
if [ "$HEALTH_STATUS" != "200" ]; then
  echo "Health check failed - HTTP $HEALTH_STATUS"
  exit 1
fi
echo "/health returned 200 OK"

# Check root endpoint
echo "Checking /..."
ROOT_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$HOST/)
if [ "$ROOT_STATUS" != "200" ]; then
  echo "Root check failed - HTTP $ROOT_STATUS"
  exit 1
fi
echo "/ returned 200 OK"

echo "=== Smoke Test Passed ==="
