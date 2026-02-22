#!/bin/bash

echo "========================================"
echo "Network Security Test - Day 24"
echo "Date: $(date)"
echo "========================================"
echo

# Test 1: List VPCs
echo "Test 1: Listing VPCs..."
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs \
  --query 'Vpcs[*].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' \
  --output table
echo

# Test 2: List Security Groups
echo "Test 2: Listing Security Groups..."
aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups \
  --query 'SecurityGroups[*].[GroupId,GroupName,Description]' \
  --output table
echo

# Test 3: Check Security Group Rules
echo "Test 3: ALB Security Group Rules..."
ALB_SG=$(aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups \
  --filters "Name=group-name,Values=myapp-alb-sg" \
  --query 'SecurityGroups[0].GroupId' \
  --output text)

if [ "$ALB_SG" != "None" ]; then
  echo "Ingress Rules:"
  aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups \
    --group-ids "$ALB_SG" \
    --query 'SecurityGroups[0].IpPermissions[*].[FromPort,ToPort,IpProtocol]' \
    --output table
fi
echo

# Test 4: List Network ACLs
echo "Test 4: Listing Network ACLs..."
aws --endpoint-url=http://localhost:4566 ec2 describe-network-acls \
  --query 'NetworkAcls[*].[NetworkAclId,Tags[?Key==`Name`].Value|[0]]' \
  --output table
echo

# Test 5: Check VPC Flow Logs
echo "Test 5: VPC Flow Logs Status..."
aws --endpoint-url=http://localhost:4566 ec2 describe-flow-logs \
  --query 'FlowLogs[*].[FlowLogId,FlowLogStatus,TrafficType]' \
  --output table
echo

# Test 6: Count subnets
echo "Test 6: Subnet Summary..."
PUBLIC_COUNT=$(aws --endpoint-url=http://localhost:4566 ec2 describe-subnets \
  --filters "Name=tag:Type,Values=Public" \
  --query 'length(Subnets)' \
  --output text)

PRIVATE_COUNT=$(aws --endpoint-url=http://localhost:4566 ec2 describe-subnets \
  --filters "Name=tag:Type,Values=Private" \
  --query 'length(Subnets)' \
  --output text)

echo "  Public Subnets: $PUBLIC_COUNT"
echo "  Private Subnets: $PRIVATE_COUNT"
echo

echo "========================================"
echo "Network security test complete"
echo "========================================"
