# Days 38 to 40 Command Recall

---

## Day 38 - Deploy RDS db.t2.micro PostgreSQL (Single-AZ), configure automated backups. STOP when not using!

```bash
# Create DB subnet group (needs 2 AZs minimum)
aws rds create-db-subnet-group \
  --db-subnet-group-name myapp-db-subnet \
  --db-subnet-group-description "MyApp DB Subnet Group" \
  --subnet-ids <subnet-id-1a> <subnet-id-1b>

# Create RDS security group (allow port 5432 from EC2 SG only)
aws ec2 create-security-group \
  --group-name rds-sg \
  --description "RDS SG" \
  --vpc-id <vpc-id>

aws ec2 authorize-security-group-ingress \
  --group-id <rds-sg-id> \
  --protocol tcp \
  --port 5432 \
  --source-group <ec2-sg-id>

# Launch RDS PostgreSQL db.t2.micro (Free Tier)
aws rds create-db-instance \
  --db-instance-identifier myapp-db \
  --db-instance-class db.t2.micro \
  --engine postgres \
  --engine-version 14 \
  --master-username admin \
  --master-user-password <strong-password> \
  --allocated-storage 20 \
  --no-multi-az \
  --db-subnet-group-name myapp-db-subnet \
  --vpc-security-group-ids <rds-sg-id> \
  --backup-retention-period 7 \
  --preferred-backup-window "02:00-03:00" \
  --no-publicly-accessible \
  --tags Key=Name,Value=myapp-db

# Wait until available
aws rds wait db-instance-available --db-instance-identifier myapp-db

# Get endpoint
aws rds describe-db-instances \
  --db-instance-identifier myapp-db \
  --query 'DBInstances[0].Endpoint.Address'

# Store DB password in SSM
aws ssm put-parameter \
  --name "/myapp/prod/db_password" \
  --value "<strong-password>" \
  --type SecureString \
  --key-id alias/myapp-key

# Test connection from EC2
psql -h <rds-endpoint> -U admin -d postgres

# STOP instance when not using (saves Free Tier hours)
aws rds stop-db-instance --db-instance-identifier myapp-db

# START when needed
aws rds start-db-instance --db-instance-identifier myapp-db

# Verify automated backups
aws rds describe-db-snapshots \
  --db-instance-identifier myapp-db \
  --snapshot-type automated
```

---

## Day 39 - Configure CloudWatch monitoring (10 metrics, 10 alarms max for free tier)

```bash
# --- 10 Key Metrics to track ---
# EC2: CPUUtilization, NetworkIn, NetworkOut, StatusCheckFailed
# RDS: DatabaseConnections, FreeStorageSpace, CPUUtilization
# Custom: RequestCount, ErrorCount, ResponseTime

# Alarm 1: EC2 High CPU
aws cloudwatch put-metric-alarm \
  --alarm-name "EC2-HighCPU" \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=<instance-id> \
  --statistic Average --period 300 --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:us-east-1:<account-id>:my-alerts

# Alarm 2: EC2 Status Check Failed
aws cloudwatch put-metric-alarm \
  --alarm-name "EC2-StatusCheckFailed" \
  --namespace AWS/EC2 \
  --metric-name StatusCheckFailed \
  --dimensions Name=InstanceId,Value=<instance-id> \
  --statistic Maximum --period 60 --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:us-east-1:<account-id>:my-alerts

# Alarm 3: RDS High CPU
aws cloudwatch put-metric-alarm \
  --alarm-name "RDS-HighCPU" \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=myapp-db \
  --statistic Average --period 300 --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:us-east-1:<account-id>:my-alerts

# Alarm 4: RDS Low Storage
aws cloudwatch put-metric-alarm \
  --alarm-name "RDS-LowStorage" \
  --namespace AWS/RDS \
  --metric-name FreeStorageSpace \
  --dimensions Name=DBInstanceIdentifier,Value=myapp-db \
  --statistic Average --period 300 --threshold 2000000000 \
  --comparison-operator LessThanThreshold \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:us-east-1:<account-id>:my-alerts

# Alarm 5: RDS DB Connections high
aws cloudwatch put-metric-alarm \
  --alarm-name "RDS-HighConnections" \
  --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBInstanceIdentifier,Value=myapp-db \
  --statistic Average --period 300 --threshold 50 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:us-east-1:<account-id>:my-alerts

# Push custom metrics from app
aws cloudwatch put-metric-data \
  --namespace "MyApp" \
  --metric-name "RequestCount" --value 1 --unit Count

aws cloudwatch put-metric-data \
  --namespace "MyApp" \
  --metric-name "ErrorCount" --value 0 --unit Count

# Alarm 6: Custom ErrorCount
aws cloudwatch put-metric-alarm \
  --alarm-name "App-HighErrors" \
  --namespace MyApp \
  --metric-name ErrorCount \
  --statistic Sum --period 60 --threshold 10 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:us-east-1:<account-id>:my-alerts

# List all alarms and states
aws cloudwatch describe-alarms \
  --query 'MetricAlarms[].{Name:AlarmName,State:StateValue}'
```

---

## Day 40 - Security hardening: IAM roles, KMS encryption, SSM Parameter Store, VPC Flow Logs

```bash
# --- IAM: tighten EC2 role to least privilege ---
aws iam create-policy \
  --policy-name myapp-ec2-policy \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": ["ssm:GetParameter", "ssm:GetParametersByPath"],
        "Resource": "arn:aws:ssm:us-east-1:*:parameter/myapp/*"
      },
      {
        "Effect": "Allow",
        "Action": ["cloudwatch:PutMetricData"],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": ["s3:GetObject"],
        "Resource": "arn:aws:s3:::my-app-artifacts/*"
      }
    ]
  }'

aws iam attach-role-policy \
  --role-name myapp-ec2-role \
  --policy-arn arn:aws:iam::<account-id>:policy/myapp-ec2-policy

# --- KMS: encrypt S3 bucket ---
aws kms create-key --description "MyApp S3 key"
aws kms create-alias --alias-name alias/myapp-s3-key --target-key-id <key-id>

aws s3api put-bucket-encryption \
  --bucket my-app-artifacts \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms",
        "KMSMasterKeyID": "alias/myapp-s3-key"
      }
    }]
  }'

# Block all public access on S3
aws s3api put-public-access-block \
  --bucket my-app-artifacts \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# --- SSM: store all secrets securely ---
aws ssm put-parameter \
  --name "/myapp/prod/db_host" \
  --value "<rds-endpoint>" \
  --type String

aws ssm put-parameter \
  --name "/myapp/prod/db_password" \
  --value "<password>" \
  --type SecureString --key-id alias/myapp-key --overwrite

# Retrieve in app (no hardcoded secrets)
aws ssm get-parameter --name "/myapp/prod/db_password" --with-decryption \
  --query 'Parameter.Value' --output text

# --- VPC Flow Logs ---
# Create log group
aws logs create-log-group --log-group-name "/vpc/flowlogs"
aws logs put-retention-policy --log-group-name "/vpc/flowlogs" --retention-in-days 7

# Enable flow logs
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids <vpc-id> \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name "/vpc/flowlogs" \
  --deliver-logs-permission-arn arn:aws:iam::<account-id>:role/myapp-ec2-role

# Query rejected traffic
aws logs start-query \
  --log-group-name "/vpc/flowlogs" \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields srcAddr, dstAddr, action | filter action="REJECT" | sort @timestamp desc | limit 20'
```

---
