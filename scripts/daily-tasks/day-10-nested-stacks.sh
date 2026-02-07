#!/bin/bash
set -e

echo "Day 10/95 - CloudFormation Nested Stacks Automation (Fixed)"
echo "==========================================================="
echo ""

ENDPOINT="http://localhost:4566"
PROFILE="localstack"
VPC_STACK="vpc-multi-env-dev"
RDS_STACK="rds-nested-dev"
CFN_DIR="$HOME/aws-devops-platform/infrastructure/cloudformation"

# Check prerequisites
echo "Step 1: Checking prerequisites..."
if ! docker ps | grep -q localstack; then
    echo "Error: LocalStack not running"
    exit 1
fi
echo "  LocalStack is running"

# Check if VPC stack exists
echo ""
echo "Step 2: Verifying existing VPC stack..."
VPC_STATUS=$(aws cloudformation describe-stacks \
    --stack-name $VPC_STACK \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE \
    2>/dev/null | jq -r '.Stacks[0].StackStatus' || echo "NOT_FOUND")

if [ "$VPC_STATUS" != "CREATE_COMPLETE" ] && [ "$VPC_STATUS" != "UPDATE_COMPLETE" ]; then
    echo "Error: VPC stack $VPC_STACK not found or not in good state"
    echo "Current status: $VPC_STATUS"
    exit 1
fi
echo "  VPC stack is ready: $VPC_STATUS"

# Get VPC outputs
echo ""
echo "Step 3: Getting VPC stack outputs..."
VPC_ID=$(aws cloudformation describe-stacks \
    --stack-name $VPC_STACK \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE \
    | jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "VPCId") | .OutputValue')

PUBLIC_SUBNET_1=$(aws cloudformation describe-stacks \
    --stack-name $VPC_STACK \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE \
    | jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "PublicSubnet1Id") | .OutputValue')

PUBLIC_SUBNET_2=$(aws cloudformation describe-stacks \
    --stack-name $VPC_STACK \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE \
    | jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "PublicSubnet2Id") | .OutputValue')

echo "  VPC ID: $VPC_ID"
echo "  Public Subnet 1: $PUBLIC_SUBNET_1"
echo "  Public Subnet 2: $PUBLIC_SUBNET_2"
echo "  Note: Using public subnets (acceptable for LocalStack learning)"

# Validate we got the values
if [ -z "$VPC_ID" ] || [ -z "$PUBLIC_SUBNET_1" ] || [ -z "$PUBLIC_SUBNET_2" ]; then
    echo "Error: Could not retrieve VPC outputs"
    exit 1
fi

# Check if RDS stack already exists
echo ""
echo "Step 4: Checking for existing RDS stack..."
EXISTING_RDS=$(aws cloudformation describe-stacks \
    --stack-name $RDS_STACK \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE \
    2>/dev/null | jq -r '.Stacks[0].StackStatus' || echo "NOT_FOUND")

if [ "$EXISTING_RDS" != "NOT_FOUND" ]; then
    echo "  RDS stack already exists with status: $EXISTING_RDS"
    echo "  Deleting old stack..."
    
    aws cloudformation delete-stack \
        --stack-name $RDS_STACK \
        --endpoint-url=$ENDPOINT \
        --profile $PROFILE
    
    echo "  Waiting for stack deletion..."
    aws cloudformation wait stack-delete-complete \
        --stack-name $RDS_STACK \
        --endpoint-url=$ENDPOINT \
        --profile $PROFILE 2>/dev/null || true
    
    sleep 5
    echo "  Old stack deleted"
fi

# Validate RDS template
echo ""
echo "Step 5: Validating RDS template..."
aws cloudformation validate-template \
    --template-body file://${CFN_DIR}/database/rds-nested.yaml \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE > /dev/null
echo "  Template is valid"

# Deploy RDS stack
echo ""
echo "Step 6: Deploying RDS nested stack..."
aws cloudformation create-stack \
    --stack-name $RDS_STACK \
    --template-body file://${CFN_DIR}/database/rds-nested.yaml \
    --parameters \
        ParameterKey=DBName,ParameterValue=myappdb \
        ParameterKey=DBUsername,ParameterValue=admin \
        ParameterKey=DBPassword,ParameterValue=TempPassword123! \
        ParameterKey=Environment,ParameterValue=dev \
        ParameterKey=VPCId,ParameterValue=$VPC_ID \
        ParameterKey=PrivateSubnet1,ParameterValue=$PUBLIC_SUBNET_1 \
        ParameterKey=PrivateSubnet2,ParameterValue=$PUBLIC_SUBNET_2 \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE

echo "  Stack creation initiated"

# Wait for stack creation
echo ""
echo "Step 7: Waiting for stack creation (this may take a few minutes)..."
aws cloudformation wait stack-create-complete \
    --stack-name $RDS_STACK \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE

echo "  Stack created successfully!"

# Show stack outputs
echo ""
echo "Step 8: RDS Stack Outputs:"
aws cloudformation describe-stacks \
    --stack-name $RDS_STACK \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE \
    | jq -r '.Stacks[0].Outputs[] | "  \(.OutputKey): \(.OutputValue)"'

# Show stack resources
echo ""
echo "Step 9: RDS Stack Resources:"
aws cloudformation describe-stack-resources \
    --stack-name $RDS_STACK \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE \
    | jq -r '.StackResources[] | "  \(.LogicalResourceId) (\(.ResourceType)): \(.ResourceStatus)"'

# Test exports
echo ""
echo "Step 10: Testing Exports:"
aws cloudformation list-exports \
    --endpoint-url=$ENDPOINT \
    --profile $PROFILE \
    | jq -r '.Exports[] | select(.Name | contains("'$RDS_STACK'")) | "  \(.Name): \(.Value)"'

# Summary
echo ""
echo "=========================================="
echo "Day 10 Tasks Completed Successfully!"
echo "=========================================="
echo ""
echo "Deployed:"
echo "  - RDS nested stack: $RDS_STACK"
echo "  - Database: PostgreSQL 13.7"
echo "  - Instance class: db.t3.micro"
echo "  - Storage: 20 GB"
echo "  - Multi-AZ: Disabled (dev environment)"
echo ""
echo "Connected to VPC:"
echo "  - VPC Stack: $VPC_STACK"
echo "  - VPC ID: $VPC_ID"
echo "  - Subnets: 2 public (using for LocalStack demo)"
echo ""
