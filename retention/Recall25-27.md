# Days 25 to 27 Command Recall

---

## Day 25 - Create 5 AWS Config rules (managed + custom) on LocalStack

```bash
# Setup Config recorder
aws --endpoint-url=http://localhost:4566 configservice put-configuration-recorder \
  --configuration-recorder name=default,roleARN=arn:aws:iam::000000000000:role/myapp-ec2-role \
  --recording-group allSupported=true

# Setup delivery channel (S3 bucket for config snapshots)
aws --endpoint-url=http://localhost:4566 s3 mb s3://config-snapshots

aws --endpoint-url=http://localhost:4566 configservice put-delivery-channel \
  --delivery-channel name=default,s3BucketName=config-snapshots

# Start recorder
aws --endpoint-url=http://localhost:4566 configservice start-configuration-recorder \
  --configuration-recorder-name default

# Managed rule 1: S3 bucket not publicly accessible
aws --endpoint-url=http://localhost:4566 configservice put-config-rule \
  --config-rule '{
    "ConfigRuleName": "s3-bucket-public-read-prohibited",
    "Source": {
      "Owner": "AWS",
      "SourceIdentifier": "S3_BUCKET_PUBLIC_READ_PROHIBITED"
    }
  }'

# Managed rule 2: MFA enabled on root
aws --endpoint-url=http://localhost:4566 configservice put-config-rule \
  --config-rule '{
    "ConfigRuleName": "root-account-mfa-enabled",
    "Source": {
      "Owner": "AWS",
      "SourceIdentifier": "ROOT_ACCOUNT_MFA_ENABLED"
    }
  }'

# Managed rule 3: EC2 instances in VPC
aws --endpoint-url=http://localhost:4566 configservice put-config-rule \
  --config-rule '{
    "ConfigRuleName": "instances-in-vpc",
    "Source": {
      "Owner": "AWS",
      "SourceIdentifier": "INSTANCES_IN_VPC"
    }
  }'

# Custom rule using Lambda
aws --endpoint-url=http://localhost:4566 configservice put-config-rule \
  --config-rule '{
    "ConfigRuleName": "custom-sg-check",
    "Source": {
      "Owner": "CUSTOM_LAMBDA",
      "SourceIdentifier": "arn:aws:lambda:us-east-1:000000000000:function:config-rule-checker",
      "SourceDetails": [{
        "EventSource": "aws.config",
        "MessageType": "ConfigurationItemChangeNotification"
      }]
    }
  }'

# Check compliance
aws --endpoint-url=http://localhost:4566 configservice describe-compliance-by-config-rule

# Get non-compliant resources
aws --endpoint-url=http://localhost:4566 configservice get-compliance-details-by-config-rule \
  --config-rule-name s3-bucket-public-read-prohibited \
  --compliance-types NON_COMPLIANT
```

---

## Day 26 - Build Lambda for security auto-remediation (simulate GuardDuty findings)

```javascript
// lambda/remediate.js
exports.handler = async (event) => {
  const AWS = require('aws-sdk');
  const ec2 = new AWS.EC2({
    endpoint: 'http://localhost:4566',
    region: 'us-east-1'
  });

  // Parse GuardDuty-style finding from EventBridge
  const finding = event.detail;
  console.log('Finding received:', JSON.stringify(finding));

  if (finding.type === 'UnauthorizedAccess:EC2/SSHBruteForce') {
    const instanceId = finding.resource.instanceDetails.instanceId;

    // Auto-remediate: isolate instance by removing security groups
    await ec2.modifyInstanceAttribute({
      InstanceId: instanceId,
      Groups: [] // remove all SGs
    }).promise();

    console.log(`Isolated instance: ${instanceId}`);
  }

  return { statusCode: 200, body: 'Remediation complete' };
};
```

```bash
# Zip and deploy Lambda
zip remediate.zip lambda/remediate.js

aws --endpoint-url=http://localhost:4566 lambda create-function \
  --function-name security-remediator \
  --runtime nodejs18.x \
  --handler remediate.handler \
  --role arn:aws:iam::000000000000:role/myapp-ec2-role \
  --zip-file fileb://remediate.zip

# Simulate a GuardDuty finding via EventBridge
aws --endpoint-url=http://localhost:4566 events put-events \
  --entries '[{
    "Source": "aws.guardduty",
    "DetailType": "GuardDuty Finding",
    "Detail": "{\"type\": \"UnauthorizedAccess:EC2/SSHBruteForce\", \"resource\": {\"instanceDetails\": {\"instanceId\": \"i-1234567890\"}}}",
    "EventBusName": "default"
  }]'

# Wire EventBridge rule → Lambda
aws --endpoint-url=http://localhost:4566 events put-rule \
  --name "GuardDutyFinding" \
  --event-pattern '{"source": ["aws.guardduty"]}' \
  --state ENABLED

aws --endpoint-url=http://localhost:4566 events put-targets \
  --rule "GuardDutyFinding" \
  --targets Id=1,Arn=arn:aws:lambda:us-east-1:000000000000:function:security-remediator

# Test Lambda directly
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name security-remediator \
  --payload '{"detail": {"type": "UnauthorizedAccess:EC2/SSHBruteForce", "resource": {"instanceDetails": {"instanceId": "i-1234"}}}}' \
  response.json

cat response.json
```

---

## Day 27 - Integrate security scanning in CI/CD (Trivy + SonarCloud free)

```bash
# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh

# Scan Docker image - all vulnerabilities
trivy image my-app:latest

# Scan and fail on CRITICAL only
trivy image --exit-code 1 --severity CRITICAL my-app:latest

# Scan filesystem (source code dependencies)
trivy fs --exit-code 1 --severity HIGH,CRITICAL .

# Scan IaC files (Terraform/CFN misconfigs)
trivy config --exit-code 1 .

# Output as JSON for reporting
trivy image --format json --output trivy-report.json my-app:latest

# SonarCloud - install scanner
npm install -g sonarqube-scanner

# sonar-project.properties
cat <<EOF > sonar-project.properties
sonar.projectKey=your_project_key
sonar.organization=your_org
sonar.sources=.
sonar.exclusions=node_modules/**,coverage/**
sonar.javascript.lcov.reportPaths=coverage/lcov.info
EOF

# Run SonarCloud scan
sonar-scanner \
  -Dsonar.login=$SONAR_TOKEN

# GitHub Actions - full security pipeline
cat <<EOF > .github/workflows/security.yml
name: Security Scan
on:
  push:
    branches: [main]
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build image
        run: docker build -t my-app:latest .

      - name: Trivy image scan
        run: trivy image --exit-code 1 --severity CRITICAL my-app:latest

      - name: Trivy IaC scan
        run: trivy config --exit-code 1 .

      - name: SonarCloud scan
        run: sonar-scanner -Dsonar.login=\${{ secrets.SONAR_TOKEN }}
EOF
```

---
