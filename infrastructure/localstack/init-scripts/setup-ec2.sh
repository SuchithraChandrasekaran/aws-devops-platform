#!/bin/bash

set -e

LOCALSTACK_ENDPOINT="http://localhost:4566"
AWS_REGION="us-east-1"
INSTANCE_TYPE="t2.micro"
AMI_ID="ami-0c55b159cbfafe1f0"
KEY_NAME="aws-devops-key"
SECURITY_GROUP_NAME="aws-devops-sg"
INSTANCE_NAME="aws-devops-sample-app"

echo "============================================================"
echo "  AWS DevOps Platform - LocalStack EC2 Setup"
echo "  Day 4/95 - Containerization Deployment"
echo "============================================================"
echo ""

echo "[1/7] Checking LocalStack status..."

if curl -s "${LOCALSTACK_ENDPOINT}/_localstack/health" > /dev/null 2>&1; then
    echo "LocalStack is running"
else
    echo "ERROR: LocalStack is not running"
    exit 1
fi
echo ""

echo "[2/7] Creating SSH key pair..."

aws --endpoint-url="${LOCALSTACK_ENDPOINT}" \
    ec2 delete-key-pair \
    --key-name "${KEY_NAME}" \
    --region "${AWS_REGION}" 2>/dev/null || true

aws --endpoint-url="${LOCALSTACK_ENDPOINT}" \
    ec2 create-key-pair \
    --key-name "${KEY_NAME}" \
    --region "${AWS_REGION}" \
    --query 'KeyMaterial' \
    --output text > "${KEY_NAME}.pem" 2>/dev/null || true

chmod 400 "${KEY_NAME}.pem" 2>/dev/null || true
echo "Key pair created"
echo ""

echo "[3/7] Creating security group..."

aws --endpoint-url="${LOCALSTACK_ENDPOINT}" \
    ec2 delete-security-group \
    --group-name "${SECURITY_GROUP_NAME}" \
    --region "${AWS_REGION}" 2>/dev/null || true

SG_ID=$(aws --endpoint-url="${LOCALSTACK_ENDPOINT}" \
    ec2 create-security-group \
    --group-name "${SECURITY_GROUP_NAME}" \
    --description "Security group for AWS DevOps sample app" \
    --region "${AWS_REGION}" \
    --query 'GroupId' \
    --output text)

echo "Security group created: ${SG_ID}"
echo ""

echo "[4/7] Configuring security group rules..."

aws --endpoint-url="${LOCALSTACK_ENDPOINT}" \
    ec2 authorize-security-group-ingress \
    --group-id "${SG_ID}" \
    --ip-permissions \
        IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges='[{CidrIp=0.0.0.0/0}]' \
        IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges='[{CidrIp=0.0.0.0/0}]' \
        IpProtocol=tcp,FromPort=3000,ToPort=3000,IpRanges='[{CidrIp=0.0.0.0/0}]' \
    --region "${AWS_REGION}" 2>/dev/null || true

echo "Security group rules configured"
echo ""

echo "[5/7] Creating EC2 instance..."

INSTANCE_ID=$(aws --endpoint-url="${LOCALSTACK_ENDPOINT}" \
    ec2 run-instances \
    --image-id "${AMI_ID}" \
    --instance-type "${INSTANCE_TYPE}" \
    --key-name "${KEY_NAME}" \
    --security-group-ids "${SG_ID}" \
    --region "${AWS_REGION}" \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "EC2 instance created: ${INSTANCE_ID}"
echo ""

echo "[6/7] Tagging instance..."

aws --endpoint-url="${LOCALSTACK_ENDPOINT}" \
    ec2 create-tags \
    --resources "${INSTANCE_ID}" \
    --tags \
        Key=Name,Value=${INSTANCE_NAME} \
        Key=Environment,Value=development \
        Key=Project,Value=aws-devops-platform \
        Key=Day,Value=4 \
    --region "${AWS_REGION}"

echo "Instance tagged"
echo ""

echo "[7/7] Retrieving instance details..."

sleep 3

PRIVATE_IP=$(aws --endpoint-url="${LOCALSTACK_ENDPOINT}" \
    ec2 describe-instances \
    --instance-ids "${INSTANCE_ID}" \
    --region "${AWS_REGION}" \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text)

PUBLIC_IP=$(aws --endpoint-url="${LOCALSTACK_ENDPOINT}" \
    ec2 describe-instances \
    --instance-ids "${INSTANCE_ID}" \
    --region "${AWS_REGION}" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo "============================================================"
echo "  EC2 Instance Created Successfully"
echo "============================================================"
echo "Instance ID:       ${INSTANCE_ID}"
echo "Instance Type:     ${INSTANCE_TYPE}"
echo "Private IP:        ${PRIVATE_IP}"
echo "Public IP:         ${PUBLIC_IP}"
echo "Security Group:    ${SG_ID}"
echo "Key Pair:          ${KEY_NAME}.pem"
echo "============================================================"
echo ""

echo "Next Steps:"
echo "1. Deploy: cd ~/aws-devops-platform/scripts/deployment && ./deploy-to-ec2.sh"
echo ""

echo "Day 4/95 - EC2 Setup Complete"
