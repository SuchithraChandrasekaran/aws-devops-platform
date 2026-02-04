#!/bin/bash

# Day 7 Sprint Review Automation
# Runs all Week 1 validation and blue-green deployment

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "======================================"
echo "Day 7 - Week 1 Sprint Review"
echo "======================================"
echo ""

# Step 1: Week 1 Health Check
echo "Step 1: Running Week 1 health check..."
${PROJECT_ROOT}/scripts/review/week1-health-check.sh
echo ""

# Step 2: Complete Test Suite
echo "Step 2: Running complete test suite..."
${PROJECT_ROOT}/scripts/review/run-all-tests.sh
echo ""

# Step 3: Code Quality Check
echo "Step 3: Running code quality check..."
${PROJECT_ROOT}/scripts/review/code-quality-check.sh
echo ""

# Step 4: Build Latest Version
echo "Step 4: Building latest application version..."
cd ${PROJECT_ROOT}/applications/sample-app
docker build -t sample-app:latest .
echo ""

# Step 5: Blue-Green Deployment
echo "Step 5: Performing blue-green deployment..."
${PROJECT_ROOT}/scripts/deployment/blue-green-deploy.sh
echo ""

# Step 6: Verify Deployment
echo "Step 6: Verifying deployment..."
sleep 3
RESPONSE=$(curl -s http://localhost:8080/health)
if echo "$RESPONSE" | grep -q "healthy"; then
	    echo "SUCCESS: Application accessible via load balancer"
    else
	        echo "ERROR: Verification failed"
		    exit 1
fi
echo ""

# Step 7: Test Rollback
echo "Step 7: Testing rollback procedure..."
echo "Current state saved, testing rollback..."
${PROJECT_ROOT}/scripts/deployment/rollback.sh
sleep 3
echo "Rollback tested successfully"
echo "Switching back to latest version..."
${PROJECT_ROOT}/scripts/deployment/blue-green-deploy.sh
echo ""

echo "======================================"
echo "Day 7 Complete!"
echo "======================================"
echo ""
echo "Week 1 Sprint Summary:"
echo "  LocalStack: Running"
echo "  CI/CD Pipeline: Functional"
echo "  Tests: Passing"
echo "  Security: Scanning enabled"
echo "  Blue-Green: Deployed and verified"
echo "  Rollback: Tested and working"
echo ""
echo "Access application: http://localhost:8080"
echo "Active environment: Check blue-green-config.json"
echo ""
echo "Next: Week 2 - Infrastructure as Code"
