# Days 12 to 15 Command Recall

---

## Day 12 - Setup remote state in LocalStack S3 + DynamoDB state locking

```bash
# Create S3 bucket for Terraform state
aws --endpoint-url=http://localhost:4566 s3 mb s3://tf-state-bucket

# Create DynamoDB table for state locking
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name tf-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "tf-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-lock"
    encrypt        = true

    # LocalStack overrides
    access_key                  = "test"
    secret_key                  = "test"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
    endpoint                    = "http://localhost:4566"
  }
}
```

```bash
# Re-init with backend
terraform init

# Verify state file in S3
aws --endpoint-url=http://localhost:4566 s3 ls s3://tf-state-bucket/dev/

# Verify lock table
aws --endpoint-url=http://localhost:4566 dynamodb scan --table-name tf-lock
```

---

## Day 13 - Store configs in SSM Parameter Store (LocalStack), reference in IaC

```bash
# Store parameters in SSM
aws --endpoint-url=http://localhost:4566 ssm put-parameter \
  --name "/myapp/dev/db_host" \
  --value "localhost" \
  --type String

aws --endpoint-url=http://localhost:4566 ssm put-parameter \
  --name "/myapp/dev/db_password" \
  --value "supersecret" \
  --type SecureString

# Get a parameter
aws --endpoint-url=http://localhost:4566 ssm get-parameter \
  --name "/myapp/dev/db_host"

# Get with decryption
aws --endpoint-url=http://localhost:4566 ssm get-parameter \
  --name "/myapp/dev/db_password" \
  --with-decryption

# Get all parameters by path
aws --endpoint-url=http://localhost:4566 ssm get-parameters-by-path \
  --path "/myapp/dev"
```

```hcl
# Reference SSM in Terraform
data "aws_ssm_parameter" "db_host" {
  name = "/myapp/dev/db_host"
}

resource "aws_instance" "app" {
  ami           = "ami-000001"
  instance_type = "t3.micro"
  user_data     = <<-EOF
    DB_HOST=${data.aws_ssm_parameter.db_host.value}
  EOF
}
```

```yaml
# Reference SSM in CloudFormation
Parameters:
  DBHost:
    Type: AWS::SSM::Parameter::Value<String>
    Default: /myapp/dev/db_host
```

---

## Day 14 - Complete IaC for entire infrastructure, test drift detection

```bash
# Apply full Terraform infrastructure
terraform apply -auto-approve

# Check current state
terraform show

# Detect drift: refresh state vs real infra
terraform plan -refresh-only

# CloudFormation drift detection
aws --endpoint-url=http://localhost:4566 cloudformation detect-stack-drift \
  --stack-name my-vpc-stack

# Get drift results
aws --endpoint-url=http://localhost:4566 cloudformation describe-stack-resource-drifts \
  --stack-name my-vpc-stack

# Terraform: import manually changed resource back into state
terraform import aws_vpc.main <vpc-id>

# Destroy and recreate to fix drift
terraform destroy -target=aws_vpc.main -auto-approve
terraform apply -target=aws_vpc.main -auto-approve
```

---

## Day 15 - Setup CloudWatch custom metrics on LocalStack, instrument application

```bash
# Put a custom metric manually
aws --endpoint-url=http://localhost:4566 cloudwatch put-metric-data \
  --namespace "MyApp" \
  --metric-name "RequestCount" \
  --value 42 \
  --unit Count

# Put metric with dimensions
aws --endpoint-url=http://localhost:4566 cloudwatch put-metric-data \
  --namespace "MyApp" \
  --metric-name "ErrorRate" \
  --dimensions Name=Environment,Value=dev \
  --value 5 \
  --unit Count

# Verify metric exists
aws --endpoint-url=http://localhost:4566 cloudwatch list-metrics \
  --namespace "MyApp"

# Get metric statistics
aws --endpoint-url=http://localhost:4566 cloudwatch get-metric-statistics \
  --namespace "MyApp" \
  --metric-name "RequestCount" \
  --start-time 2026-01-01T00:00:00Z \
  --end-time 2026-12-31T00:00:00Z \
  --period 3600 \
  --statistics Sum
```

```javascript
// Instrument Node.js app to emit custom metrics
const { CloudWatchClient, PutMetricDataCommand } = require("@aws-sdk/client-cloudwatch");

const client = new CloudWatchClient({
  region: "us-east-1",
  endpoint: "http://localhost:4566",
  credentials: { accessKeyId: "test", secretAccessKey: "test" }
});

async function putMetric(name, value) {
  await client.send(new PutMetricDataCommand({
    Namespace: "MyApp",
    MetricData: [{ MetricName: name, Value: value, Unit: "Count" }]
  }));
}

// Call in your route handler
putMetric("RequestCount", 1);
```

---
