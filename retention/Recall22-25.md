# Days 22 to 24 Command Recall

---

## Day 22 - Implement least-privilege IAM roles for all services

```bash
# Create IAM role with trust policy (EC2 example)
aws --endpoint-url=http://localhost:4566 iam create-role \
  --role-name myapp-ec2-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }]
  }'

# Create least-privilege policy (S3 read-only on specific bucket)
aws --endpoint-url=http://localhost:4566 iam create-policy \
  --policy-name myapp-s3-read \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::my-app-artifacts",
        "arn:aws:s3:::my-app-artifacts/*"
      ]
    }]
  }'

# Attach policy to role
aws --endpoint-url=http://localhost:4566 iam attach-role-policy \
  --role-name myapp-ec2-role \
  --policy-arn arn:aws:iam::000000000000:policy/myapp-s3-read

# Create instance profile and attach role
aws --endpoint-url=http://localhost:4566 iam create-instance-profile \
  --instance-profile-name myapp-profile

aws --endpoint-url=http://localhost:4566 iam add-role-to-instance-profile \
  --instance-profile-name myapp-profile \
  --role-name myapp-ec2-role

# Attach instance profile to EC2
aws --endpoint-url=http://localhost:4566 ec2 associate-iam-instance-profile \
  --instance-id <instance-id> \
  --iam-instance-profile Name=myapp-profile

# List attached policies on a role
aws --endpoint-url=http://localhost:4566 iam list-attached-role-policies \
  --role-name myapp-ec2-role

# Simulate policy (check permissions)
aws --endpoint-url=http://localhost:4566 iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::000000000000:role/myapp-ec2-role \
  --action-names s3:GetObject \
  --resource-arns arn:aws:s3:::my-app-artifacts/myfile.zip
```

---

## Day 23 - Setup SSM Parameter Store SecureString (KMS encrypted) for secrets

```bash
# Create KMS key
aws --endpoint-url=http://localhost:4566 kms create-key \
  --description "MyApp secrets key"
# Note the KeyId from output

# Create alias for the key
aws --endpoint-url=http://localhost:4566 kms create-alias \
  --alias-name alias/myapp-key \
  --target-key-id <key-id>

# Store SecureString parameter with KMS encryption
aws --endpoint-url=http://localhost:4566 ssm put-parameter \
  --name "/myapp/prod/db_password" \
  --value "supersecretpassword" \
  --type SecureString \
  --key-id alias/myapp-key

aws --endpoint-url=http://localhost:4566 ssm put-parameter \
  --name "/myapp/prod/api_key" \
  --value "myapikey123" \
  --type SecureString \
  --key-id alias/myapp-key

# Get with decryption
aws --endpoint-url=http://localhost:4566 ssm get-parameter \
  --name "/myapp/prod/db_password" \
  --with-decryption

# Get all secrets by path
aws --endpoint-url=http://localhost:4566 ssm get-parameters-by-path \
  --path "/myapp/prod" \
  --with-decryption \
  --recursive

# Reference in Terraform
cat <<EOF >> main.tf
data "aws_ssm_parameter" "db_password" {
  name            = "/myapp/prod/db_password"
  with_decryption = true
}
EOF

# Rotate a parameter value
aws --endpoint-url=http://localhost:4566 ssm put-parameter \
  --name "/myapp/prod/db_password" \
  --value "newpassword456" \
  --type SecureString \
  --key-id alias/myapp-key \
  --overwrite
```

---

## Day 24 - Harden network security, implement VPC Flow Logs analysis

```bash
# Enable VPC Flow Logs → CloudWatch
aws --endpoint-url=http://localhost:4566 ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids <vpc-id> \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name "/vpc/flowlogs" \
  --deliver-logs-permission-arn arn:aws:iam::000000000000:role/myapp-ec2-role

# Verify flow logs created
aws --endpoint-url=http://localhost:4566 ec2 describe-flow-logs

# Restrict security group - remove all open ingress
aws --endpoint-url=http://localhost:4566 ec2 revoke-security-group-ingress \
  --group-id <sg-id> \
  --protocol -1 \
  --cidr 0.0.0.0/0

# Allow only specific ports
aws --endpoint-url=http://localhost:4566 ec2 authorize-security-group-ingress \
  --group-id <sg-id> --protocol tcp --port 443 --cidr 0.0.0.0/0

aws --endpoint-url=http://localhost:4566 ec2 authorize-security-group-ingress \
  --group-id <sg-id> --protocol tcp --port 22 --cidr 10.0.0.0/8

# Create NACL and attach to subnet
aws --endpoint-url=http://localhost:4566 ec2 create-network-acl \
  --vpc-id <vpc-id>

aws --endpoint-url=http://localhost:4566 ec2 create-network-acl-entry \
  --network-acl-id <nacl-id> \
  --rule-number 100 \
  --protocol tcp \
  --port-range From=443,To=443 \
  --cidr-block 0.0.0.0/0 \
  --rule-action allow \
  --ingress

# Query flow logs in CloudWatch Logs Insights
aws --endpoint-url=http://localhost:4566 logs start-query \
  --log-group-name "/vpc/flowlogs" \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, srcAddr, dstAddr, action | filter action="REJECT" | sort @timestamp desc | limit 20'
```

---
