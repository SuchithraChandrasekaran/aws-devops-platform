#!/bin/bash

# Week 1 Health Check
# Validates all Week 1 components

echo "======================================"
echo "Week 1 Health Check"
echo "======================================"

PASSED=0
FAILED=0

# Check 1: LocalStack running
echo ""
echo "Check 1: LocalStack Status"
if docker ps | grep -q localstack; then
	    echo "PASS: LocalStack is running"
	        PASSED=$((PASSED + 1))
	else
		    echo "FAIL: LocalStack is not running"
		        FAILED=$((FAILED + 1))
fi

# Check 2: S3 buckets exist
echo ""
echo "Check 2: S3 Buckets"
BUCKETS=$(aws --endpoint-url=http://localhost:4566 --profile localstack s3 ls 2>/dev/null | wc -l)
if [ $BUCKETS -ge 2 ]; then
	    echo "PASS: S3 buckets configured ($BUCKETS buckets)"
	        PASSED=$((PASSED + 1))
	else
		    echo "FAIL: S3 buckets missing"
		        FAILED=$((FAILED + 1))
fi

# Check 3: Docker images exist
echo ""
echo "Check 3: Docker Images"
if docker images | grep -q sample-app; then
	    echo "PASS: Sample app image exists"
	        PASSED=$((PASSED + 1))
	else
		    echo "FAIL: Sample app image missing"
		        FAILED=$((FAILED + 1))
fi

# Check 4: Tests exist and pass
echo ""
echo "Check 4: Test Suite"
cd ~/aws-devops-platform/applications/sample-app
if npm test > /dev/null 2>&1; then
	    echo "PASS: All tests passing"
	        PASSED=$((PASSED + 1))
	else
		    echo "FAIL: Tests failing or missing"
		        FAILED=$((FAILED + 1))
fi

# Check 5: Security scanning configured
echo ""
echo "Check 5: Security Scanning"
if command -v trivy > /dev/null 2>&1; then
	    echo "PASS: Trivy installed"
	        PASSED=$((PASSED + 1))
	else
		    echo "FAIL: Trivy not installed"
		        FAILED=$((FAILED + 1))
fi

# Check 6: GitHub Actions workflows
echo ""
echo "Check 6: GitHub Actions"
if [ -f ~/aws-devops-platform/.github/workflows/pipeline-complete.yml ]; then
	    echo "PASS: CI/CD workflow configured"
	        PASSED=$((PASSED + 1))
	else
		    echo "FAIL: CI/CD workflow missing"
		        FAILED=$((FAILED + 1))
fi

# Summary
echo ""
echo "======================================"
echo "Health Check Summary"
echo "======================================"
echo "Passed: ${PASSED}"
echo "Failed: ${FAILED}"
echo ""

if [ $FAILED -eq 0 ]; then
	    echo "ALL CHECKS PASSED - Week 1 Complete!"
	        exit 0
	else
		    echo "Some checks failed - review before continuing"
		        exit 1
fi
