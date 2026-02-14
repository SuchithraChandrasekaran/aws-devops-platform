#!/bin/bash

echo "========================================"
echo "SNS Topics Testing - Day 17"
echo "Date: $(date)"
echo "========================================"
echo

# Test 1: List SNS topics
echo "Test 1: Listing SNS topics..."
aws --endpoint-url=http://localhost:4566 sns list-topics
echo

# Test 2: Get critical topic details
echo "Test 2: Getting critical topic attributes..."
CRITICAL_TOPIC=$(aws --endpoint-url=http://localhost:4566 sns list-topics \
  --query 'Topics[?contains(TopicArn, `critical`)].TopicArn' \
  --output text)

echo "Critical Topic ARN: $CRITICAL_TOPIC"
aws --endpoint-url=http://localhost:4566 sns get-topic-attributes \
  --topic-arn "$CRITICAL_TOPIC"
echo

# Test 3: Get warning topic details
echo "Test 3: Getting warning topic attributes..."
WARNING_TOPIC=$(aws --endpoint-url=http://localhost:4566 sns list-topics \
  --query 'Topics[?contains(TopicArn, `warning`)].TopicArn' \
  --output text)

echo "Warning Topic ARN: $WARNING_TOPIC"
aws --endpoint-url=http://localhost:4566 sns get-topic-attributes \
  --topic-arn "$WARNING_TOPIC"
echo

# Test 4: Publish test message to critical topic
echo "Test 4: Publishing test notification to critical topic..."
aws --endpoint-url=http://localhost:4566 sns publish \
  --topic-arn "$CRITICAL_TOPIC" \
  --subject "Critical Alert - Test" \
  --message "This is a test critical alert from Day 17 CloudWatch Alarms testing"
echo

# Test 5: Publish test message to warning topic
echo "Test 5: Publishing test notification to warning topic..."
aws --endpoint-url=http://localhost:4566 sns publish \
  --topic-arn "$WARNING_TOPIC" \
  --subject "Warning Alert - Test" \
  --message "This is a test warning alert from Day 17 CloudWatch Alarms testing"
echo

# Test 6: List subscriptions
echo "Test 6: Listing all subscriptions..."
aws --endpoint-url=http://localhost:4566 sns list-subscriptions
echo

# Test 7: List subscriptions by topic
echo "Test 7: Listing subscriptions for critical topic..."
aws --endpoint-url=http://localhost:4566 sns list-subscriptions-by-topic \
  --topic-arn "$CRITICAL_TOPIC"
echo

echo "========================================"
echo "SNS testing complete"
echo "========================================"
