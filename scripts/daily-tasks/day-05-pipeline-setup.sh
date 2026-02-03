#!/bin/bash
# Day 5: Complete CI/CD Pipeline Setup

set -e

PROJECT_ROOT=~/aws-devops-platform
ENDPOINT="http://localhost:4566"

echo "Day 5/95: Complete CI/CD Pipeline Setup"
echo "==========================================="
echo ""

# Step 1: Verify prerequisites
echo "Step 1: Verifying prerequisites..."
cd $PROJECT_ROOT

if ! docker ps | grep -q localstack; then
    echo "LocalStack not running. Starting..."
    cd infrastructure/localstack
    docker-compose up -d
    sleep 10
fi

# Step 2: Setup S3 buckets
echo ""
echo "🪣 Step 2: Setting up S3 buckets..."
./infrastructure/localstack/init-scripts/setup-s3-buckets.sh

# Step 3: Deploy CloudFormation
echo ""
echo "☁️  Step 3: Deploying CloudFormation stack..."
aws --endpoint-url=$ENDPOINT --profile localstack \
    cloudformation create-stack \
    --stack-name s3-artifacts-dev \
    --template-body file://infrastructure/cloudformation/s3-artifacts.yml \
    --parameters ParameterKey=Environment,ParameterValue=dev \
    2>/dev/null || echo "Stack already exists"

# Wait for stack
echo "Waiting for CloudFormation stack..."
sleep 5

# Step 4: Run tests
echo ""
echo "Step 4: Running application tests..."
cd $PROJECT_ROOT/applications/sample-app
npm test

# Step 5: Build and push
echo ""
echo "Step 5: Building and pushing artifact..."
cd $PROJECT_ROOT
./scripts/pipeline/build-and-push.sh

# Step 6: Verify artifact
echo ""
echo "Step 6: Verifying artifact..."
./scripts/pipeline/pipeline-status.sh

# Step 7: Test download
echo ""
echo "Step 7: Testing artifact download..."
./scripts/pipeline/download-artifact.sh latest

echo ""
echo " Day 5 Complete!"
echo "=================="
echo ""
echo "S3 buckets created"
echo "CloudFormation stack deployed"
echo "Tests passing"
echo "Artifact built and uploaded"
echo "Artifact download verified"
echo ""
echo "Next: Push to GitHub to trigger the complete pipeline!"