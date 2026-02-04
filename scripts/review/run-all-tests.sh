#!/bin/bash

# Complete Test Suite Runner
# Runs all tests from Week 1


PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "======================================"
echo "Running Complete Test Suite"
echo "======================================"

# Unit tests
echo ""
echo "Running unit tests..."
cd ${PROJECT_ROOT}/applications/sample-app
npm test -- --testPathPattern=app.test.js

# Integration tests
echo ""
echo "Running integration tests..."
npm test -- --testPathPattern=integration.test.js

# API tests
echo ""
echo "Running API tests..."
npm test -- --testPathPattern=api.test.js

# Coverage report
echo ""
echo "Generating coverage report..."
npm test -- --coverage

# Security scan
echo ""
echo "Running security scan..."
${PROJECT_ROOT}/scripts/security/trivy-scan.sh sample-app:latest

echo ""
echo "======================================"
echo "All Tests Complete"
echo "======================================"
