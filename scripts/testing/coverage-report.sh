#!/bin/bash
# Generate and display coverage report

set -e

echo "Generating coverage report..."
echo "=============================="

cd ~/aws-devops-platform/applications/sample-app

# Generate coverage
npm test -- --coverage --coverageReporters=text --coverageReporters=html

echo ""
echo "Coverage report generated!"
echo "HTML report: applications/sample-app/coverage/index.html"
echo ""

# Display summary
if [ -f coverage/coverage-summary.json ]; then
    echo "Coverage Summary:"
    cat coverage/coverage-summary.json | grep -A 10 "total"
fi