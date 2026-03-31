#!/bin/bash
# DR Script: Recover EC2 from AMI
# Usage: ./scripts/dr/recover-ec2.sh <AMI_ID> <SUBNET_ID> <SG_ID> <KEY_NAME>
# Run when: EC2 instance is terminated, corrupted, or unrecoverable

set -e

AMI_ID="${1:?Usage: $0 <AMI_ID> <SUBNET_ID> <SG_ID> <KEY_NAME>}"
SUBNET_ID="${2:?}"
SG_ID="${3:?}"
KEY_NAME="${4:?}"
REGION="us-east-1"
INSTANCE_TYPE="t2.micro"  # Free tier

echo "========================================"
echo "EC2 Recovery - $(date)"
echo "========================================"
echo "AMI       : $AMI_ID"
echo "Subnet    : $SUBNET_ID"
echo "SG        : $SG_ID"
echo "Key pair  : $KEY_NAME"
echo ""

# Confirm before proceeding
read -p "Proceed with recovery? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Aborted."
  exit 1
fi

echo "Launching recovery instance..."
NEW_INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --subnet-id "$SUBNET_ID" \
  --security-group-ids "$SG_ID" \
  --key-name "$KEY_NAME" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=dr-recovered},{Key=Purpose,Value=DR},{Key=RestoredFrom,Value=$AMI_ID}]" \
  --region "$REGION" \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "Instance launching: $NEW_INSTANCE_ID"
echo "Waiting for running state..."

aws ec2 wait instance-running \
  --instance-ids "$NEW_INSTANCE_ID" \
  --region "$REGION"

# Get public IP
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$NEW_INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text \
  --region "$REGION")

echo ""
echo "========================================"
echo "Recovery complete"
echo "Instance : $NEW_INSTANCE_ID"
echo "Public IP: $PUBLIC_IP"
echo "Connect  : ssh -i ~/.ssh/${KEY_NAME}.pem ec2-user@${PUBLIC_IP}"
echo "========================================"
echo ""
echo "NEXT STEPS:"
echo "  1. Verify application is running: curl http://${PUBLIC_IP}"
echo "  2. Update DNS/Route53 to point to new IP"
echo "  3. Update any Elastic IP associations"
echo "  4. Notify team of new instance details"
echo "  5. Investigate root cause of original failure"
