#!/bin/bash
set -e

echo "Running test suite..."
echo "===================="

cd ~/aws-devops-platform/applications/sample-app
rm -rf coverage/

echo ""
echo "Running all tests..."
npm test

echo ""
echo "All tests completed!"
echo "===================="
