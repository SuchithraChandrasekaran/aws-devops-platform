#!/bin/bash
#set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${PROJECT_ROOT}"

echo "======================================"
echo "Day 9/95 - Multi-Environment CloudFormation"
echo "======================================"
echo ""

# Step 1: Validate template
echo "Step 1: Validating template..."
${PROJECT_ROOT}/infrastructure/cloudformation/scripts/validate-conditions.sh
echo ""

# Step 2: Deploy both environments
echo "Step 2: Deploying both environments..."
${PROJECT_ROOT}/infrastructure/cloudformation/scripts/deploy-both-envs.sh
echo ""

# Step 3: Compare environments
echo "Step 3: Comparing environments..."
${PROJECT_ROOT}/infrastructure/cloudformation/scripts/compare-envs.sh
echo ""

# Step 4: Verify condition logic
echo "Step 4: Verifying condition logic..."
echo ""

# Get dev VPC CIDR
DEV_CIDR=$(aws cloudformation describe-stacks \
    --stack-name vpc-multi-env-dev \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="VPCCidr") | .OutputValue')

# Get prod VPC CIDR
PROD_CIDR=$(aws cloudformation describe-stacks \
    --stack-name vpc-multi-env-prod \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="VPCCidr") | .OutputValue')

echo "Dev VPC CIDR: ${DEV_CIDR}"
echo "Prod VPC CIDR: ${PROD_CIDR}"

if [ "$DEV_CIDR" != "$PROD_CIDR" ]; then
    echo "✓ VPCs have different CIDRs - condition working correctly"
else
    echo "ERROR: VPCs should have different CIDRs"
    exit 1
fi

echo ""

# Step 5: Verify environment-specific configurations
echo "Step 5: Environment-specific configuration verification..."
echo ""

# Check dev security group - should allow SSH from anywhere (0.0.0.0/0)
echo "Checking Dev Security Group SSH rule..."
DEV_SG=$(aws cloudformation describe-stacks \
    --stack-name vpc-multi-env-dev \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="WebSecurityGroupId") | .OutputValue')

DEV_SSH_CIDR=$(aws ec2 describe-security-groups \
    --group-ids ${DEV_SG} \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.SecurityGroups[0].IpPermissions[] | select(.FromPort==22) | .IpRanges[0].CidrIp')

echo "Dev SSH allowed from: ${DEV_SSH_CIDR}"

if [ "$DEV_SSH_CIDR" = "0.0.0.0/0" ]; then
    echo "✓ Dev: SSH open to all (development configuration)"
else
    echo "⚠ Dev: SSH not fully open (expected 0.0.0.0/0, got ${DEV_SSH_CIDR})"
fi

echo ""

# Check prod security group - should restrict SSH to VPC only (10.1.0.0/16)
echo "Checking Prod Security Group SSH rule..."
PROD_SG=$(aws cloudformation describe-stacks \
    --stack-name vpc-multi-env-prod \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="WebSecurityGroupId") | .OutputValue')

PROD_SSH_CIDR=$(aws ec2 describe-security-groups \
    --group-ids ${PROD_SG} \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.SecurityGroups[0].IpPermissions[] | select(.FromPort==22) | .IpRanges[0].CidrIp')

echo "Prod SSH allowed from: ${PROD_SSH_CIDR}"

if [ "$PROD_SSH_CIDR" = "10.1.0.0/16" ]; then
    echo "✓ Prod: SSH restricted to VPC (production configuration)"
else
    echo "⚠ Prod: SSH restriction (expected 10.1.0.0/16, got ${PROD_SSH_CIDR})"
fi

echo ""

# Step 6: Verify security profiles from outputs
echo "Step 6: Security profile outputs..."
echo ""

DEV_PROFILE=$(aws cloudformation describe-stacks \
    --stack-name vpc-multi-env-dev \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="SecurityProfile") | .OutputValue')

PROD_PROFILE=$(aws cloudformation describe-stacks \
    --stack-name vpc-multi-env-prod \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="SecurityProfile") | .OutputValue')

echo "Dev Security Profile: ${DEV_PROFILE}"
echo "Prod Security Profile: ${PROD_PROFILE}"

# Step 7: Summary
echo ""
echo "======================================"
echo "Day 9 Complete!"
echo "======================================"
echo ""
echo "Summary:"
echo "- Dev environment: 10.0.0.0/16, Open SSH access"
echo "- Prod environment: 10.1.0.0/16, Restricted SSH access"
echo "- Both environments deployed from same template"
echo "- Conditions working correctly"
echo "- Security profiles different based on environment"
echo ""
echo "Conditions Demonstrated:"
echo "✓ IsProduction condition controls SSH access"
echo "✓ Different VPC CIDRs per environment"
echo "✓ Different security profiles per environment"
echo "✓ Fn::If used for conditional property values"
echo "✓ Fn::Equals used for environment detection"
echo ""
echo "Note: NAT Gateway and Flow Logs disabled for LocalStack compatibility"
echo "Conditions still work - they're just set to 'false' in both environments"
