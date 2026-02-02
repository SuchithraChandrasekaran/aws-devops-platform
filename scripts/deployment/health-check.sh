#!/bin/bash
# Health Check Script

set -e

# Configuration
ENDPOINT="http://localhost:4566"
REGION="us-east-1"

echo "Starting health check..."

# Check LocalStack
if curl -sf "${ENDPOINT}/_localstack/health" > /dev/null 2>&1; then
    echo "LocalStack: Running"
else
    echo "LocalStack: Not running"
    exit 1
fi

# Check EC2 instance
INSTANCE_ID=$(aws --endpoint-url="$ENDPOINT" \
    ec2 describe-instances \
    --filters "Name=tag:Name,Values=aws-devops-sample-app" \
              "Name=instance-state-name,Values=running" \
    --region "$REGION" \
    --query 'Reservations[0].Instances[0].InstanceId' \
    --output text 2>/dev/null)

if [ -z "$INSTANCE_ID" ] || [ "$INSTANCE_ID" == "None" ]; then
    echo "EC2 Instance: Not found"
    exit 1
fi

echo "EC2 Instance: Running ($INSTANCE_ID)"

# Check deployment status
DEPLOY_STATUS=$(aws --endpoint-url="$ENDPOINT" \
    ec2 describe-tags \
    --filters "Name=resource-id,Values=$INSTANCE_ID" \
              "Name=key,Values=DeploymentStatus" \
    --region "$REGION" \
    --query 'Tags[0].Value' \
    --output text 2>/dev/null)

if [ "$DEPLOY_STATUS" == "deployed" ]; then
    echo "Deployment: Deployed"
else
    echo "Deployment: Not deployed"
fi

# Check local Docker container
if docker ps | grep -q "aws-devops-sample-app"; then
    echo "Local Container: Running"
    
    if curl -sf http://localhost:3000/health > /dev/null 2>&1; then
        echo "Health Endpoint: OK"
    else
        echo "Health Endpoint: Not responding"
    fi
else
    echo "Local Container: Not running"
fi

echo "Health check complete"