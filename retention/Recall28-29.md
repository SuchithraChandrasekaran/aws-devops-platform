# Days 28 to 29 Command Recall

---

## Day 28 - Complete security baseline, security audit, penetration testing

```bash
# --- Security Baseline Checklist ---

# 1. Ensure no S3 buckets are public
aws --endpoint-url=http://localhost:4566 s3api put-public-access-block \
  --bucket my-app-artifacts \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# 2. Enable S3 versioning
aws --endpoint-url=http://localhost:4566 s3api put-bucket-versioning \
  --bucket my-app-artifacts \
  --versioning-configuration Status=Enabled

# 3. Enable S3 encryption
aws --endpoint-url=http://localhost:4566 s3api put-bucket-encryption \
  --bucket my-app-artifacts \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms",
        "KMSMasterKeyID": "alias/myapp-key"
      }
    }]
  }'

# 4. Audit IAM - list all roles and policies
aws --endpoint-url=http://localhost:4566 iam list-roles
aws --endpoint-url=http://localhost:4566 iam list-policies --scope Local

# 5. Check for overly permissive security groups
aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups \
  --filters Name=ip-permission.cidr,Values=0.0.0.0/0

# 6. Audit Config compliance
aws --endpoint-url=http://localhost:4566 configservice describe-compliance-by-config-rule \
  --compliance-types NON_COMPLIANT

# --- Penetration Testing (local simulation) ---

# Nmap port scan against LocalStack
nmap -sV -p 4566 localhost

# Check for open ports on running containers
docker ps --format "{{.Names}}: {{.Ports}}"

# Test security group rules - attempt blocked port
curl -v --max-time 3 http://localhost:8080 || echo "Port blocked as expected"

# Trivy full audit
trivy image --severity HIGH,CRITICAL my-app:latest
trivy config --severity HIGH,CRITICAL .
trivy fs --severity HIGH,CRITICAL .

# Check CloudTrail logs for suspicious activity
aws --endpoint-url=http://localhost:4566 logs filter-log-events \
  --log-group-name "CloudTrail/DefaultLogGroup" \
  --filter-pattern "{ $.errorCode = \"AccessDenied\" }"
```

---

## Day 29 - Create 5 Lambda functions: auto-stop-resources, auto-tag, backup-verify, security-remediation, health-check

```bash
# Helper: deploy a Lambda function
deploy_lambda() {
  zip $1.zip lambda/$1.js
  aws --endpoint-url=http://localhost:4566 lambda create-function \
    --function-name $1 \
    --runtime nodejs18.x \
    --handler $1.handler \
    --role arn:aws:iam::000000000000:role/myapp-ec2-role \
    --zip-file fileb://$1.zip
}
```

```javascript
// lambda/auto-stop-resources.js
// Stops EC2 instances tagged with AutoStop=true after hours
exports.handler = async () => {
  const AWS = require('aws-sdk');
  const ec2 = new AWS.EC2({ endpoint: 'http://localhost:4566', region: 'us-east-1' });

  const { Reservations } = await ec2.describeInstances({
    Filters: [{ Name: 'tag:AutoStop', Values: ['true'] },
              { Name: 'instance-state-name', Values: ['running'] }]
  }).promise();

  const ids = Reservations.flatMap(r => r.Instances.map(i => i.InstanceId));
  if (ids.length) await ec2.stopInstances({ InstanceIds: ids }).promise();
  console.log('Stopped:', ids);
};
```

```javascript
// lambda/auto-tag.js
// Tags new EC2 instances with Creator and CreatedAt
exports.handler = async (event) => {
  const AWS = require('aws-sdk');
  const ec2 = new AWS.EC2({ endpoint: 'http://localhost:4566', region: 'us-east-1' });

  const instanceId = event.detail['instance-id'];
  await ec2.createTags({
    Resources: [instanceId],
    Tags: [
      { Key: 'CreatedAt', Value: new Date().toISOString() },
      { Key: 'ManagedBy', Value: 'auto-tag-lambda' }
    ]
  }).promise();
  console.log('Tagged:', instanceId);
};
```

```javascript
// lambda/backup-verify.js
// Verifies S3 backup bucket has recent objects
exports.handler = async () => {
  const AWS = require('aws-sdk');
  const s3 = new AWS.S3({ endpoint: 'http://localhost:4566', region: 'us-east-1' });

  const { Contents } = await s3.listObjectsV2({ Bucket: 'my-app-artifacts' }).promise();
  const recent = Contents.filter(obj => {
    const age = (Date.now() - new Date(obj.LastModified)) / 3600000;
    return age < 24;
  });

  if (recent.length === 0) throw new Error('No recent backups found!');
  console.log(`${recent.length} recent backups verified`);
};
```

```javascript
// lambda/security-remediation.js
// Isolates EC2 instance on GuardDuty finding
exports.handler = async (event) => {
  const AWS = require('aws-sdk');
  const ec2 = new AWS.EC2({ endpoint: 'http://localhost:4566', region: 'us-east-1' });

  const instanceId = event.detail?.resource?.instanceDetails?.instanceId;
  if (!instanceId) return;

  await ec2.modifyInstanceAttribute({ InstanceId: instanceId, Groups: [] }).promise();
  console.log('Isolated instance:', instanceId);
};
```

```javascript
// lambda/health-check.js
// Checks app endpoint and sends alert if down
exports.handler = async () => {
  const https = require('https');
  const AWS = require('aws-sdk');
  const sns = new AWS.SNS({ endpoint: 'http://localhost:4566', region: 'us-east-1' });

  try {
    await new Promise((res, rej) => {
      https.get('http://localhost:3000', r => r.statusCode === 200 ? res() : rej()).on('error', rej);
    });
    console.log('Health check passed');
  } catch {
    await sns.publish({
      TopicArn: 'arn:aws:sns:us-east-1:000000000000:my-alerts',
      Message: 'App is DOWN',
      Subject: 'Health Check Failed'
    }).promise();
  }
};
```

```bash
# Deploy all 5 functions
mkdir -p lambda
deploy_lambda auto-stop-resources
deploy_lambda auto-tag
deploy_lambda backup-verify
deploy_lambda security-remediation
deploy_lambda health-check

# List all functions
aws --endpoint-url=http://localhost:4566 lambda list-functions

# Test each function
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name health-check --payload '{}' response.json && cat response.json

# Schedule auto-stop with EventBridge (runs at 8pm daily)
aws --endpoint-url=http://localhost:4566 events put-rule \
  --name "AutoStopSchedule" \
  --schedule-expression "cron(0 20 * * ? *)" \
  --state ENABLED

aws --endpoint-url=http://localhost:4566 events put-targets \
  --rule "AutoStopSchedule" \
  --targets Id=1,Arn=arn:aws:lambda:us-east-1:000000000000:function:auto-stop-resources
```

---
