# 95-Day Tracker - Days 51 to 53 Command Recall

---

## Day 51 - CloudTrail Logging and Analysis

```bash
# Create S3 bucket for CloudTrail logs
aws s3 mb s3://myapp-cloudtrail-logs

# Add bucket policy to allow CloudTrail to write
aws s3api put-bucket-policy \
  --bucket myapp-cloudtrail-logs \
  --policy '{
    "Version": "2012-10-17",
    "Statement": [{
      "Sid": "AWSCloudTrailAclCheck",
      "Effect": "Allow",
      "Principal": { "Service": "cloudtrail.amazonaws.com" },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::myapp-cloudtrail-logs"
    },
    {
      "Sid": "AWSCloudTrailWrite",
      "Effect": "Allow",
      "Principal": { "Service": "cloudtrail.amazonaws.com" },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::myapp-cloudtrail-logs/AWSLogs/<account-id>/*",
      "Condition": { "StringEquals": { "s3:x-amz-acl": "bucket-owner-full-control" } }
    }]
  }'

# Create trail
aws cloudtrail create-trail \
  --name myapp-trail \
  --s3-bucket-name myapp-cloudtrail-logs \
  --include-global-service-events \
  --is-multi-region-trail \
  --enable-log-file-validation

# Start logging
aws cloudtrail start-logging --name myapp-trail

# Verify trail status
aws cloudtrail get-trail-status --name myapp-trail

# Enable CloudWatch Logs integration
aws logs create-log-group --log-group-name "CloudTrail/myapp"

aws cloudtrail update-trail \
  --name myapp-trail \
  --cloud-watch-logs-log-group-arn arn:aws:logs:us-east-1:<account-id>:log-group:CloudTrail/myapp:* \
  --cloud-watch-logs-role-arn arn:aws:iam::<account-id>:role/myapp-ec2-role

# Query: find all API calls by a user
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=Username,AttributeValue=admin \
  --start-time $(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ)

# Query: find all failed API calls
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=ConsoleLogin \
  --start-time $(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ)

# Query: find all EC2 terminations
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=TerminateInstances

# CloudWatch Logs Insights - find AccessDenied errors
aws logs start-query \
  --log-group-name "CloudTrail/myapp" \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, eventName, userIdentity.arn, errorCode
    | filter errorCode = "AccessDenied"
    | sort @timestamp desc
    | limit 20'

# Get query results
aws logs get-query-results --query-id <query-id>
```

---

## Day 52 - AWS Config Rules (5 max free)

```bash
# Start Config recorder
aws configservice put-configuration-recorder \
  --configuration-recorder name=default,roleARN=arn:aws:iam::<account-id>:role/myapp-ec2-role \
  --recording-group allSupported=true

# Setup delivery channel
aws configservice put-delivery-channel \
  --delivery-channel name=default,s3BucketName=myapp-cloudtrail-logs

aws configservice start-configuration-recorder \
  --configuration-recorder-name default

# Rule 1: S3 bucket public read prohibited
aws configservice put-config-rule \
  --config-rule '{
    "ConfigRuleName": "s3-bucket-public-read-prohibited",
    "Source": {
      "Owner": "AWS",
      "SourceIdentifier": "S3_BUCKET_PUBLIC_READ_PROHIBITED"
    }
  }'

# Rule 2: EC2 instances in VPC
aws configservice put-config-rule \
  --config-rule '{
    "ConfigRuleName": "instances-in-vpc",
    "Source": {
      "Owner": "AWS",
      "SourceIdentifier": "INSTANCES_IN_VPC"
    }
  }'

# Rule 3: RDS storage encrypted
aws configservice put-config-rule \
  --config-rule '{
    "ConfigRuleName": "rds-storage-encrypted",
    "Source": {
      "Owner": "AWS",
      "SourceIdentifier": "RDS_STORAGE_ENCRYPTED"
    }
  }'

# Rule 4: IAM password policy
aws configservice put-config-rule \
  --config-rule '{
    "ConfigRuleName": "iam-password-policy",
    "Source": {
      "Owner": "AWS",
      "SourceIdentifier": "IAM_PASSWORD_POLICY"
    }
  }'

# Rule 5: CloudTrail enabled
aws configservice put-config-rule \
  --config-rule '{
    "ConfigRuleName": "cloud-trail-enabled",
    "Source": {
      "Owner": "AWS",
      "SourceIdentifier": "CLOUD_TRAIL_ENABLED"
    }
  }'

# Check compliance across all rules
aws configservice describe-compliance-by-config-rule \
  --query 'ComplianceByConfigRules[].{Rule:ConfigRuleName,Compliance:Compliance.ComplianceType}'

# Get non-compliant resources for a rule
aws configservice get-compliance-details-by-config-rule \
  --config-rule-name s3-bucket-public-read-prohibited \
  --compliance-types NON_COMPLIANT

# Run evaluation manually
aws configservice start-config-rules-evaluation \
  --config-rule-names s3-bucket-public-read-prohibited instances-in-vpc
```

---

## Day 53 - Cost Allocation Tags on All Resources

```bash
# Activate cost allocation tags in Billing console (required first)
# Done via AWS Console: Billing → Cost allocation tags → Activate

# Tag EC2 instance
aws ec2 create-tags \
  --resources <instance-id> \
  --tags \
    Key=Project,Value=myapp \
    Key=Environment,Value=prod \
    Key=Owner,Value=devops-team \
    Key=CostCenter,Value=engineering

# Tag RDS instance
aws rds add-tags-to-resource \
  --resource-name arn:aws:rds:us-east-1:<account-id>:db:myapp-db \
  --tags \
    Key=Project,Value=myapp \
    Key=Environment,Value=prod \
    Key=Owner,Value=devops-team \
    Key=CostCenter,Value=engineering

# Tag S3 bucket
aws s3api put-bucket-tagging \
  --bucket my-app-artifacts \
  --tagging 'TagSet=[
    {Key=Project,Value=myapp},
    {Key=Environment,Value=prod},
    {Key=Owner,Value=devops-team},
    {Key=CostCenter,Value=engineering}
  ]'

# Tag SNS topic
aws sns tag-resource \
  --resource-arn arn:aws:sns:us-east-1:<account-id>:myapp-alerts \
  --tags \
    Key=Project,Value=myapp \
    Key=Environment,Value=prod

# Tag Lambda functions
aws lambda tag-resource \
  --resource arn:aws:lambda:us-east-1:<account-id>:function:health-check \
  --tags Project=myapp,Environment=prod,Owner=devops-team

# Tag CloudWatch alarms
aws cloudwatch tag-resource \
  --resource-arn arn:aws:cloudwatch:us-east-1:<account-id>:alarm:App-HighErrors \
  --tags Key=Project,Value=myapp Key=Environment,Value=prod

# Verify tags on EC2
aws ec2 describe-tags \
  --filters Name=resource-id,Values=<instance-id>

# Find all untagged EC2 instances
aws ec2 describe-instances \
  --query 'Reservations[].Instances[?!Tags || length(Tags)==`0`].InstanceId'

# Cost breakdown by tag using Cost Explorer
aws ce get-cost-and-usage \
  --time-period Start=$(date -u -d '30 days ago' +%Y-%m-%d),End=$(date -u +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=TAG,Key=Project

# Enforce tagging via IAM policy (deny launch without tags)
aws iam create-policy \
  --policy-name enforce-tagging \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Deny",
      "Action": "ec2:RunInstances",
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": {
        "Null": {
          "aws:RequestTag/Project": "true"
        }
      }
    }]
  }'
```

---
