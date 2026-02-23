#!/bin/bash

echo "========================================"
echo "AWS Config Testing - Day 25"
echo "Date: $(date)"
echo "========================================"
echo

# Test 1: List Config recorders
echo "Test 1: Config Recorders..."
aws --endpoint-url=http://localhost:4566 configservice describe-configuration-recorders
echo

# Test 2: Check recorder status
echo "Test 2: Recorder Status..."
aws --endpoint-url=http://localhost:4566 configservice describe-configuration-recorder-status
echo

# Test 3: List Config rules
echo "Test 3: Config Rules..."
aws --endpoint-url=http://localhost:4566 configservice describe-config-rules
echo

# Test 4: Check delivery channel
echo "Test 4: Delivery Channel..."
aws --endpoint-url=http://localhost:4566 configservice describe-delivery-channels
echo

echo "========================================"
echo "Config testing complete"
echo "========================================"
