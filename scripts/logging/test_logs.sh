#!/bin/bash

echo "========================================"
echo "CloudWatch Logs Testing"
echo "========================================"
echo

# Test 1: Send logs
echo "Test 1: Sending logs to CloudWatch..."
python3 scripts/logging/centralized_logger.py

sleep 2

# Test 2: Retrieve logs from application log group
echo -e "\nTest 2: Retrieving application logs..."
aws --endpoint-url=http://localhost:4566 logs filter-log-events \
  --log-group-name /aws/application/myapp \
  --log-stream-names app-stream

# Test 3: Retrieve error logs
echo -e "\nTest 3: Retrieving error logs..."
aws --endpoint-url=http://localhost:4566 logs filter-log-events \
  --log-group-name /aws/errors/myapp \
  --log-stream-names error-stream

echo -e "\nLogging test complete"
