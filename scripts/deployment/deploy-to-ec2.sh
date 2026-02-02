#!/bin/bash

set -e

LOCALSTACK_ENDPOINT="http://localhost:4566"
AWS_REGION="us-east-1"
DOCKER_IMAGE="aws-devops-sample-app"
DOCKER_TAG="latest"

echo "============================================================"
echo "  AWS DevOps Platform - EC2 Deployment"
echo "  Day 4/95 - Container Deployment"
echo "============================================================"
echo ""

echo "[1/6] Finding EC2 instance..."

INSTANCE_ID=$(aws --endpoint-url="${LOCALSTACK_ENDPOINT}" \
                  ec2 describe-instances \
                  --filters "Name=tag:Name,Values=aws-devops-sample-app" \
                            "Name=instance-state-name,Values=running" \
                  --region "${AWS_REGION}" \
                  --query 'Reservations[0].Instances[0].InstanceId' \
                  --output text 2>/dev/null)

if [ "$INSTANCE_ID" == "None" ] || [ -z "$INSTANCE_ID" ]; then
    echo "ERROR: No running EC2 instance found"
    echo "Please run the setup script first:"
    echo "  ./infrastructure/localstack/init-scripts/setup-ec2.sh"
    exit 1
fi

echo "Found instance: ${INSTANCE_ID}"
echo ""

echo "[2/6] Retrieving instance IP address..."

INSTANCE_IP=$(aws --endpoint-url="${LOCALSTACK_ENDPOINT}" \
                  ec2 describe-instances \
                  --instance-ids "${INSTANCE_ID}" \
                  --region "${AWS_REGION}" \
                  --query 'Reservations[0].Instances[0].PublicIpAddress' \
                  --output text)

if [ -z "$INSTANCE_IP" ] || [ "$INSTANCE_IP" == "None" ]; then
    INSTANCE_IP=$(aws --endpoint-url="${LOCALSTACK_ENDPOINT}" \
                      ec2 describe-instances \
                      --instance-ids "${INSTANCE_ID}" \
                      --region "${AWS_REGION}" \
                      --query 'Reservations[0].Instances[0].PrivateIpAddress' \
                      --output text)
fi

echo "Instance IP: ${INSTANCE_IP}"
echo ""

echo "[3/6] Checking Docker image..."

if ! docker images | grep -q "${DOCKER_IMAGE}"; then
    echo "ERROR: Docker image '${DOCKER_IMAGE}' not found locally"
    echo "Please build the image first:"
    echo "  cd applications/sample-app && docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
    exit 1
fi

echo "Docker image found"
echo ""

echo "[4/6] Tagging deployment on EC2 instance..."

aws --endpoint-url="${LOCALSTACK_ENDPOINT}" \
    ec2 create-tags \
    --resources "${INSTANCE_ID}" \
    --tags "Key=DeploymentStatus,Value=deployed" \
           "Key=DeploymentTime,Value=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
           "Key=DockerImage,Value=${DOCKER_IMAGE}:${DOCKER_TAG}" \
    --region "${AWS_REGION}"

echo "Deployment tagged"
echo ""

echo "Note: In real AWS environment, this would:"
echo "  1. Transfer Docker image to EC2 via SCP"
echo "  2. Load image on EC2 instance"
echo "  3. Start container on port 3000"
echo ""

echo "[5/6] Verifying deployment..."

DEPLOY_STATUS=$(aws --endpoint-url="${LOCALSTACK_ENDPOINT}" \
                    ec2 describe-tags \
                    --filters "Name=resource-id,Values=${INSTANCE_ID}" \
                              "Name=key,Values=DeploymentStatus" \
                    --region "${AWS_REGION}" \
                    --query 'Tags[0].Value' \
                    --output text)

if [ "$DEPLOY_STATUS" == "deployed" ]; then
    echo "Deployment verification passed"
else
    echo "WARNING: Deployment status unclear"
fi
echo ""

echo "[6/6] Deployment summary..."

DEPLOY_TIME=$(aws --endpoint-url="${LOCALSTACK_ENDPOINT}" \
                  ec2 describe-tags \
                  --filters "Name=resource-id,Values=${INSTANCE_ID}" \
                            "Name=key,Values=DeploymentTime" \
                  --region "${AWS_REGION}" \
                  --query 'Tags[0].Value' \
                  --output text)

echo ""
echo "============================================================"
echo "  Deployment Complete"
echo "============================================================"
echo "Instance ID:       ${INSTANCE_ID}"
echo "Instance IP:       ${INSTANCE_IP}"
echo "Docker Image:      ${DOCKER_IMAGE}:${DOCKER_TAG}"
echo "Deploy Time:       ${DEPLOY_TIME}"
echo "============================================================"
echo ""

echo "Next steps:"
echo "  Run health check: ./health-check.sh"
echo ""

echo "Day 4/95 - EC2 Deployment Complete"
