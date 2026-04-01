#!/bin/bash
# Audit Logger - Append an event to DynamoDB platform-audit-log
# Usage: ./scripts/audit-log.sh <resource_id> <action> <result> <details> [day]
# Example: ./scripts/audit-log.sh "ec2/i-0abc" "ami-created" "success" "DR baseline AMI" 62

RESOURCE_ID="${1:?Usage: $0 <resource_id> <action> <result> <details> [day]}"
ACTION="${2:?}"
RESULT="${3:?}"
DETAILS="${4:?}"
DAY="${5:-0}"
TABLE="platform-audit-log"
REGION="us-east-1"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

aws dynamodb put-item \
  --table-name "$TABLE" \
  --item "{
    \"resource_id\": {\"S\": \"$RESOURCE_ID\"},
    \"timestamp\":   {\"S\": \"$TIMESTAMP\"},
    \"action\":      {\"S\": \"$ACTION\"},
    \"actor\":       {\"S\": \"$(whoami)@$(hostname)\"},
    \"result\":      {\"S\": \"$RESULT\"},
    \"details\":     {\"S\": \"$DETAILS\"},
    \"day\":         {\"N\": \"$DAY\"}
  }" \
  --region "$REGION"

echo "Logged: [$TIMESTAMP] $RESOURCE_ID | $ACTION | $RESULT"
