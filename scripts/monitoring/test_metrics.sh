#!/bin/bash

echo "========================================"
echo "CloudWatch Metrics Testing - Day 15"
echo "Date: $(date)"
echo "========================================"
echo

# Test 1: Publish metrics
echo "Test 1: Publishing custom metrics..."
python3 scripts/monitoring/publish_metrics.py

echo
echo "Test 2: Verify metrics in CloudWatch..."
aws --endpoint-url=http://localhost:4566 cloudwatch list-metrics \
    --namespace MyApp/Performance

echo
echo "Test 3: Get metric statistics..."
aws --endpoint-url=http://localhost:4566 cloudwatch get-metric-statistics \
    --namespace MyApp/Performance \
    --metric-name RequestCount \
    --start-time $(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 60 \
    --statistics Sum

echo
echo "✓ Metrics test complete"
