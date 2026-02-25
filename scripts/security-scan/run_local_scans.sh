#!/bin/bash

echo "========================================"
echo "Local Security Scanning - Day 27"
echo "Date: $(date)"
echo "========================================"
echo

cd ~/aws-devops-platform

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running"
    exit 1
fi

# Build the test image
echo "Step 1: Building Docker image..."
cd security-scanning
docker build -t myapp:scan . > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "  Image built successfully"
else
    echo "  Failed to build image"
    exit 1
fi
cd ..
echo

# Run Trivy scan
echo "Step 2: Running Trivy container scan..."
if command -v trivy &> /dev/null; then
    trivy image --severity HIGH,CRITICAL myapp:scan
    echo "  Trivy scan complete"
else
    echo "  Trivy not installed. Install with: brew install trivy"
fi
echo

# Run Safety check
echo "Step 3: Running Python dependency check..."
if command -v safety &> /dev/null; then
    cd security-scanning
    safety check -r requirements.txt --output text
    cd ..
    echo "  Safety check complete"
else
    echo "  Safety not installed. Install with: pip install safety"
fi
echo

# Run Bandit SAST
echo "Step 4: Running Bandit SAST scan..."
if command -v bandit &> /dev/null; then
    bandit -r security-scanning/app
    echo "  Bandit scan complete"
else
    echo "  Bandit not installed. Install with: pip install bandit"
fi
echo

# Run tfsec on Terraform
echo "Step 5: Running tfsec on Terraform code..."
if command -v tfsec &> /dev/null; then
    tfsec infrastructure/terraform --soft-fail
    echo "  tfsec scan complete"
else
    echo "  tfsec not installed. Install with: brew install tfsec"
fi
echo

echo "========================================"
echo "Security scanning complete"
echo "========================================"
