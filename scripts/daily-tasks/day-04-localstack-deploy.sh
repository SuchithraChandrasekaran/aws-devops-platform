#!/bin/bash
# LocalStack Deployment Script

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "Starting Day 4 deployment workflow..."
echo ""

# Check prerequisites
echo "[1/8] Checking prerequisites..."
command -v docker >/dev/null || { echo "Error: Docker not found"; exit 1; }
command -v aws >/dev/null || { echo "Error: AWS CLI not found"; exit 1; }
command -v python3 >/dev/null || { echo "Error: Python not found"; exit 1; }
echo "All prerequisites met"
echo ""

# Configure AWS CLI
echo "[2/8] Configuring AWS CLI..."
if ! aws configure list --profile localstack &> /dev/null; then
    aws configure set aws_access_key_id test --profile localstack
    aws configure set aws_secret_access_key test --profile localstack
    aws configure set region us-east-1 --profile localstack
    aws configure set output json --profile localstack
fi
echo "AWS CLI configured"
echo ""

# Start LocalStack
echo "[3/8] Starting LocalStack..."
cd "${PROJECT_ROOT}/infrastructure/localstack"
if ! docker ps | grep -q "localstack-aws-devops"; then
    docker-compose up -d
    echo "Waiting for LocalStack..."
    sleep 10
fi
echo "LocalStack running"
echo ""

# Build Docker image
echo "[4/8] Building Docker image..."
cd "${PROJECT_ROOT}/applications/sample-app"
docker build -t aws-devops-sample-app:latest -t aws-devops-sample-app:v1 .
echo "Docker image built"
echo ""

# Create EC2 instance
echo "[5/8] Creating EC2 instance..."
cd "${PROJECT_ROOT}/infrastructure/localstack/init-scripts"
chmod +x setup-ec2.sh
./setup-ec2.sh
echo ""

# Deploy to EC2
echo "[6/8] Deploying to EC2..."
cd "${PROJECT_ROOT}/scripts/deployment"
chmod +x deploy-to-ec2.sh
./deploy-to-ec2.sh
echo ""

# Run health checks
echo "[7/8] Running health checks..."
chmod +x health-check.sh
./health-check.sh
echo ""

# Summary
echo "[8/8] Summary"
echo "Day 4 deployment complete!"
echo ""
echo "What was accomplished:"
echo "  - LocalStack configured and running"
echo "  - Docker image built"
echo "  - EC2 instance created"
echo "  - Application deployed"
echo "  - Health checks passed"
echo ""
echo "Next steps:"
echo "  1. git add . && git commit -m 'Day 4 - LocalStack EC2 deployment'"
echo "  2. git push origin main"
echo ""
echo "Useful commands:"
echo "  - Check EC2: aws --endpoint-url=http://localhost:4566 ec2 describe-instances"
echo "  - Stop LocalStack: cd infrastructure/localstack && docker-compose down"
echo "  - Health check: ./scripts/deployment/health-check.sh"
echo ""

cd "${PROJECT_ROOT}"
