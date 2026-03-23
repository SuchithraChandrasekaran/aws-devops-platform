#!/bin/bash
# Tag audit - checks required tags on all major resources
# Usage: ./scripts/tag-audit.sh

REQUIRED_KEYS=("Project" "Environment" "Owner")
ISSUES=0

check_tags() {
  local resource_type=$1
  local resource_id=$2
  local tags_json=$3

  for key in "${REQUIRED_KEYS[@]}"; do
    if ! echo "$tags_json" | grep -q "\"$key\""; then
      echo "MISSING TAG [$key] on $resource_type: $resource_id"
      ISSUES=$((ISSUES + 1))
    fi
  done
}

echo "=== Tag Audit - $(date) ==="

# EC2
echo ""
echo "--- EC2 Instances ---"
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[InstanceId,Tags]' \
  --output json --region us-east-1 | \
python3 -c "
import json, sys
data = json.load(sys.stdin)
for reservation in data:
  for instance in reservation:
    iid = instance[0]
    tags = json.dumps(instance[1] or [])
    for key in ['Project','Environment','Owner']:
      if key not in tags:
        print(f'MISSING TAG [{key}] on EC2: {iid}')
"

# Lambda
echo ""
echo "--- Lambda Functions ---"
for FUNC in $(aws lambda list-functions \
  --query 'Functions[*].FunctionName' \
  --output text --region us-east-1); do
  FUNC_ARN=$(aws lambda get-function \
    --function-name $FUNC \
    --query 'Configuration.FunctionArn' \
    --output text --region us-east-1)
  TAGS=$(aws lambda list-tags \
    --resource $FUNC_ARN \
    --output json --region us-east-1)
  for key in Project Environment Owner; do
    if ! echo "$TAGS" | grep -q "\"$key\""; then
      echo "MISSING TAG [$key] on Lambda: $FUNC"
    fi
  done
done

# S3
echo ""
echo "--- S3 Buckets ---"
for BUCKET in $(aws s3 ls | awk '{print $3}'); do
  TAGS=$(aws s3api get-bucket-tagging --bucket $BUCKET 2>/dev/null || echo '{}')
  for key in Project Environment Owner; do
    if ! echo "$TAGS" | grep -q "\"$key\""; then
      echo "MISSING TAG [$key] on S3: $BUCKET"
    fi
  done
done

echo ""
echo "=== Audit complete ==="
