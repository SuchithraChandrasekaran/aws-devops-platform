# Day 83 Recall - D59 to D63

---

## D59 - Security Group Audit and Optimization

```bash
# List all security groups
aws ec2 describe-security-groups \
  --query 'SecurityGroups[].{ID:GroupId,Name:GroupName,VPC:VpcId}'

# Find SGs with open 0.0.0.0/0 ingress
aws ec2 describe-security-groups \
  --filters Name=ip-permission.cidr,Values=0.0.0.0/0 \
  --query 'SecurityGroups[].{ID:GroupId,Name:GroupName}'

# Find unused SGs (not attached to any instance)
aws ec2 describe-instances \
  --query 'Reservations[].Instances[].SecurityGroups[].GroupId' \
  --output text | tr '\t' '\n' | sort -u > used_sgs.txt

aws ec2 describe-security-groups \
  --query 'SecurityGroups[].GroupId' \
  --output text | tr '\t' '\n' | sort -u > all_sgs.txt

diff all_sgs.txt used_sgs.txt

# Remove overly permissive rule
aws ec2 revoke-security-group-ingress \
  --group-id <sg-id> \
  --protocol tcp --port 22 --cidr 0.0.0.0/0

# Replace with specific IP
aws ec2 authorize-security-group-ingress \
  --group-id <sg-id> \
  --protocol tcp --port 22 --cidr <your-ip>/32

# Delete unused SG
aws ec2 delete-security-group --group-id <sg-id>
```

---

## D60 - IAM Role Refinement

```bash
# List all roles
aws iam list-roles --query 'Roles[].{Name:RoleName,Created:CreateDate}'

# List attached policies on a role
aws iam list-attached-role-policies --role-name <role-name>

# List inline policies
aws iam list-role-policies --role-name <role-name>

# Get policy details
aws iam get-policy-version \
  --policy-arn <policy-arn> \
  --version-id v1

# Simulate permissions
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::<account-id>:role/<role-name> \
  --action-names s3:PutObject ec2:TerminateInstances \
  --resource-arns "*"

# Remove overly broad policy
aws iam detach-role-policy \
  --role-name <role-name> \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Attach least-privilege policy
aws iam attach-role-policy \
  --role-name <role-name> \
  --policy-arn <least-privilege-policy-arn>

# Generate IAM credential report
aws iam generate-credential-report
aws iam get-credential-report --query 'Content' --output text | base64 -d
```

---

## D61 - DR Runbook Automation

```bash
# Create SSM runbook for DR
aws ssm create-document \
  --name "DR-Failover" \
  --document-type "Automation" \
  --content '{
    "schemaVersion": "0.3",
    "description": "DR failover procedure",
    "mainSteps": [
      {
        "name": "TakeSnapshot",
        "action": "aws:executeAwsApi",
        "inputs": {
          "Service": "rds",
          "Api": "CreateDBSnapshot",
          "DBInstanceIdentifier": "<db-id>",
          "DBSnapshotIdentifier": "dr-snapshot-{{global:DATE}}"
        }
      },
      {
        "name": "NotifyTeam",
        "action": "aws:executeAwsApi",
        "inputs": {
          "Service": "sns",
          "Api": "Publish",
          "TopicArn": "<sns-arn>",
          "Message": "DR failover initiated"
        }
      }
    ]
  }'

# Execute DR runbook
aws ssm start-automation-execution \
  --document-name "DR-Failover"

# Check execution status
aws ssm describe-automation-executions \
  --filters Key=DocumentNamePrefix,Values=DR-Failover

# Step Functions DR workflow trigger
aws stepfunctions start-execution \
  --state-machine-arn <state-machine-arn> \
  --input '{"trigger": "dr-event"}'

# Check execution
aws stepfunctions list-executions \
  --state-machine-arn <state-machine-arn> \
  --status-filter RUNNING
```

---

## D62 - DynamoDB Table Creation (Free Tier)

```bash
# Create table
aws dynamodb create-table \
  --table-name <table-name> \
  --attribute-definitions \
    AttributeName=PK,AttributeType=S \
    AttributeName=SK,AttributeType=S \
  --key-schema \
    AttributeName=PK,KeyType=HASH \
    AttributeName=SK,KeyType=RANGE \
  --billing-mode PAY_PER_REQUEST

# Wait until active
aws dynamodb wait table-exists --table-name <table-name>

# Put item
aws dynamodb put-item \
  --table-name <table-name> \
  --item '{"PK": {"S": "user#1"}, "SK": {"S": "profile"}, "name": {"S": "Alice"}}'

# Get item
aws dynamodb get-item \
  --table-name <table-name> \
  --key '{"PK": {"S": "user#1"}, "SK": {"S": "profile"}}'

# Query by PK
aws dynamodb query \
  --table-name <table-name> \
  --key-condition-expression "PK = :pk" \
  --expression-attribute-values '{":pk": {"S": "user#1"}}'

# Scan table
aws dynamodb scan --table-name <table-name>

# Enable TTL
aws dynamodb update-time-to-live \
  --table-name <table-name> \
  --time-to-live-specification Enabled=true,AttributeName=ttl

# Delete table
aws dynamodb delete-table --table-name <table-name>
```

---

## D63 - Full Integration Testing

```bash
# EC2 health
aws ec2 describe-instances \
  --filters Name=instance-state-name,Values=running \
  --query 'Reservations[].Instances[].{ID:InstanceId,IP:PublicIpAddress}'

curl -f https://<domain>/health && echo "App OK"

# RDS health
aws rds describe-db-instances \
  --query 'DBInstances[].{ID:DBInstanceIdentifier,Status:DBInstanceStatus}'

# CloudWatch alarms
aws cloudwatch describe-alarms \
  --query 'MetricAlarms[].{Name:AlarmName,State:StateValue}'

# Lambda test
aws lambda invoke \
  --function-name <function-name> \
  --payload '{}' response.json && cat response.json

# SNS test
aws sns publish \
  --topic-arn <sns-arn> \
  --message "Integration test ping"

# DynamoDB test
aws dynamodb put-item \
  --table-name <table-name> \
  --item '{"PK": {"S": "test"}, "SK": {"S": "e2e"}}'

aws dynamodb get-item \
  --table-name <table-name> \
  --key '{"PK": {"S": "test"}, "SK": {"S": "e2e"}}'

# Config compliance
aws configservice describe-compliance-by-config-rule \
  --query 'ComplianceByConfigRules[].{Rule:ConfigRuleName,Status:Compliance.ComplianceType}'

# Cost check
aws ce get-cost-and-usage \
  --time-period Start=$(date -u +%Y-%m-01),End=$(date -u +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost
```

---
