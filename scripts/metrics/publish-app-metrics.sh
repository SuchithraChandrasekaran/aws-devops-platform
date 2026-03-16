#!/bin/bash

# publish-app-metrics.sh
# Publishes custom app metrics to CloudWatch
# Usage: bash publish-app-metrics.sh
# Run this from EC2 where the app is running

set -e

NAMESPACE="aws-devops/App"
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== Publishing App Metrics ==="
echo "Instance: $INSTANCE_ID"
echo "Namespace: $NAMESPACE"
echo "Time: $TIMESTAMP"

# Get app stats from Docker container
APP_NAME="sample-app"
CONTAINER_RUNNING=$(docker ps --filter "name=$APP_NAME" --format "{{.Names}}" | wc -l)

if [ "$CONTAINER_RUNNING" -eq 0 ]; then
  echo "App container not running - publishing zero metrics"
  REQUEST_COUNT=0
  ERROR_COUNT=0
  RESPONSE_TIME=0
  ACTIVE_CONNECTIONS=0
else
  # Simulate realistic metrics (replace with real app metrics when app exposes them)
  REQUEST_COUNT=$(shuf -i 50-200 -n 1)
  ERROR_COUNT=$(shuf -i 0-5 -n 1)
  RESPONSE_TIME=$(shuf -i 50-300 -n 1)
  ACTIVE_CONNECTIONS=$(shuf -i 1-20 -n 1)
fi

# Publish metrics
aws cloudwatch put-metric-data \
  --namespace "$NAMESPACE" \
  --metric-data \
    MetricName=RequestCount,Value=$REQUEST_COUNT,Unit=Count,Dimensions=[{Name=InstanceId,Value=$INSTANCE_ID}] \
    MetricName=ErrorCount,Value=$ERROR_COUNT,Unit=Count,Dimensions=[{Name=InstanceId,Value=$INSTANCE_ID}] \
    MetricName=ResponseTime,Value=$RESPONSE_TIME,Unit=Milliseconds,Dimensions=[{Name=InstanceId,Value=$INSTANCE_ID}] \
    MetricName=ActiveConnections,Value=$ACTIVE_CONNECTIONS,Unit=Count,Dimensions=[{Name=InstanceId,Value=$INSTANCE_ID}]

echo "Published:"
echo "  RequestCount     : $REQUEST_COUNT"
echo "  ErrorCount       : $ERROR_COUNT"
echo "  ResponseTime     : ${RESPONSE_TIME}ms"
echo "  ActiveConnections: $ACTIVE_CONNECTIONS"
echo "=== Done ==="
