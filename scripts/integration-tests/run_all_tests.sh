#!/bin/bash

echo "========================================"
echo "Week 3 Complete Integration Test"
echo "========================================"
echo

# Pre-flight checks
echo "Pre-flight Checks:"
echo "-----------------"

echo -n "LocalStack: "
if docker ps | grep -q localstack; then
    echo "Running"
else
    echo "Not running"
    exit 1
fi

echo -n "Prometheus: "
if docker ps | grep -q prometheus; then
    echo "Running"
else
    echo "Not running"
    exit 1
fi

echo -n "Grafana: "
if docker ps | grep -q grafana; then
    echo "Running"
else
    echo "Not running"
    exit 1
fi

echo

# Run Python integration tests
python3 scripts/integration-tests/test_monitoring_stack.py

# Additional CLI verification
echo
echo "========================================"
echo "Additional Verifications"
echo "========================================"

echo
echo "CloudWatch Dashboard:"
aws --endpoint-url=http://localhost:4566 cloudwatch get-dashboard \
  --dashboard-name operations-dashboard \
  --query 'DashboardName' \
  --output text 2>/dev/null && echo "  Dashboard exists" || echo "  Dashboard missing"

echo
echo "SNS Subscriptions:"
SUBS=$(aws --endpoint-url=http://localhost:4566 sns list-subscriptions \
  --query 'length(Subscriptions)' \
  --output text 2>/dev/null)
echo "  Total subscriptions: $SUBS"

echo
echo "EventBridge Event Buses:"
aws --endpoint-url=http://localhost:4566 events list-event-buses \
  --query 'EventBuses[*].Name' \
  --output text 2>/dev/null

echo
echo "========================================"
echo "Integration test complete!"
echo "========================================"
