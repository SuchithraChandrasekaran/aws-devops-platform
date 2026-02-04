#!/bin/bash
# Day 6: Automated testing and security scanning setup

set -e

echo "======================================"
echo "DAY 6 Testing & Security Scanning"
echo "======================================"
echo ""

# Step 1: Verify prerequisites
echo "Step 1: Verifying prerequisites..."
cd ~/aws-devops-platform

if [ ! -d "applications/sample-app" ]; then
    echo "ERROR: Sample app not found"
    exit 1
fi

if ! docker ps | grep -q localstack; then
    echo "ERROR: LocalStack not running"
    exit 1
fi

echo "Prerequisites OK"
echo ""

# Step 2: Install dependencies
echo "Step 2: Installing test dependencies..."
cd applications/sample-app
npm install
echo ""

# Step 3: Run tests
echo "Step 3: Running test suite..."
cd ~/aws-devops-platform
./scripts/testing/run-tests.sh
echo ""

# Step 4: Generate coverage
echo "Step 4: Generating coverage report..."
./scripts/testing/coverage-report.sh
echo ""

# Step 5: Check quality gates
echo "Step 5: Checking quality gates..."
./scripts/testing/test-quality-gate.sh
echo ""

# Step 6: Build Docker image
echo "Step 6: Building Docker image..."
cd applications/sample-app
docker build -t sample-app:latest .
echo ""

# Step 7: Run security scan
echo "Step 7: Running security scan..."
cd ~/aws-devops-platform
./scripts/security/trivy-scan.sh sample-app:latest
echo ""

# Step 8: Generate vulnerability report
echo "Step 8: Generating vulnerability report..."
./scripts/security/vulnerability-report.sh
echo ""

# Step 9: Check security gates
echo "Step 9: Checking security gates..."
if ./scripts/security/security-gate.sh sample-app:latest; then
    echo "Security gate PASSED"
else
    echo "WARNING: Security gate failed - review vulnerabilities"
fi
echo ""

echo "======================================"
echo "Day 6 Complete!"
echo "======================================"
echo ""
echo "Summary:"
echo "  Tests run and passing"
echo "  Coverage report generated"
echo "  Quality gates checked"
echo "  Security scan completed"
echo "  Vulnerability report available"
echo ""
echo "Next: Push to GitHub to trigger CI/CD pipeline"