#!/bin/bash

echo "========================================"
echo "EventBridge Verification - Day 20"
echo "Date: $(date)"
echo "========================================"
echo

# Test 1: List all event buses
echo "Test 1: Listing event buses..."
aws --endpoint-url=http://localhost:4566 events list-event-buses \
  --query 'EventBuses[*].[Name,Arn]' \
  --output table
echo

# Test 2: List rules on default bus
echo "Test 2: Rules on default event bus..."
aws --endpoint-url=http://localhost:4566 events list-rules \
  --query 'Rules[*].[Name,State,ScheduleExpression,EventPattern]' \
  --output table
echo

# Test 3: List rules on custom bus
echo "Test 3: Rules on myapp-event-bus..."
aws --endpoint-url=http://localhost:4566 events list-rules \
  --event-bus-name myapp-event-bus \
  --query 'Rules[*].[Name,State]' \
  --output table
echo

# Test 4: Check targets for health check rule
echo "Test 4: Targets for health check rule..."
aws --endpoint-url=http://localhost:4566 events list-targets-by-rule \
  --rule app-health-check \
  --query 'Targets[*].[Id,Arn]' \
  --output table
echo

# Test 5: Check targets for alarm state change rule
echo "Test 5: Targets for alarm state change rule..."
aws --endpoint-url=http://localhost:4566 events list-targets-by-rule \
  --rule alarm-state-change \
  --query 'Targets[*].[Id,Arn]' \
  --output table
echo

# Test 6: Publish test event and verify
echo "Test 6: Publishing test event..."
aws --endpoint-url=http://localhost:4566 events put-events \
  --entries '[{
    "Source": "myapp.test",
    "DetailType": "TestEvent",
    "Detail": "{\"message\": \"EventBridge verification test\", \"day\": \"20\"}",
    "EventBusName": "myapp-event-bus"
  }]'
echo

# Summary
echo "========================================"
echo "EventBridge Rule Summary:"
RULE_COUNT=$(aws --endpoint-url=http://localhost:4566 events list-rules --query 'length(Rules)' --output text)
CUSTOM_RULE_COUNT=$(aws --endpoint-url=http://localhost:4566 events list-rules --event-bus-name myapp-event-bus --query 'length(Rules)' --output text 2>/dev/null || echo "0")
echo "  Default bus rules: $RULE_COUNT"
echo "  Custom bus rules:  $CUSTOM_RULE_COUNT"
echo "========================================"
echo "EventBridge verification complete"
echo "========================================"
