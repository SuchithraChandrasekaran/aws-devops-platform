# Days 9 to 11 Command Recall

---

## Day 9 - Multi-environment CloudFormation (dev/prod using conditions and parameters)

```yaml
# vpc-multi-env.yml
AWSTemplateFormatVersion: '2010-09-09'
Parameters:
  Environment:
    Type: String
    AllowedValues: [dev, prod]
    Default: dev

Conditions:
  IsProd: !Equals [!Ref Environment, prod]

Resources:
  MyVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !If [IsProd, 10.0.0.0/16, 10.1.0.0/16]

  MySubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MyVPC
      CidrBlock: !If [IsProd, 10.0.1.0/24, 10.1.1.0/24]
      AvailabilityZone: us-east-1a
```

```bash
# Deploy dev stack
aws --endpoint-url=http://localhost:4566 cloudformation create-stack \
  --stack-name vpc-dev \
  --template-body file://vpc-multi-env.yml \
  --parameters ParameterKey=Environment,ParameterValue=dev

# Deploy prod stack
aws --endpoint-url=http://localhost:4566 cloudformation create-stack \
  --stack-name vpc-prod \
  --template-body file://vpc-multi-env.yml \
  --parameters ParameterKey=Environment,ParameterValue=prod

# Check both stacks
aws --endpoint-url=http://localhost:4566 cloudformation describe-stacks
```

---

## Day 10 - Create nested stack for RDS (simulated on LocalStack)

```yaml
# rds.yml - child stack
AWSTemplateFormatVersion: '2010-09-09'
Parameters:
  VpcId:
    Type: String
Resources:
  MyDB:
    Type: AWS::RDS::DBInstance
    Properties:
      DBInstanceClass: db.t3.micro
      Engine: mysql
      MasterUsername: admin
      MasterUserPassword: password123
      AllocatedStorage: 20
```

```yaml
# main.yml - parent stack referencing nested stack
AWSTemplateFormatVersion: '2010-09-09'
Resources:
  VPCStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.localhost.localstack.cloud:4566/my-templates/vpc-multi-env.yml

  RDSStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.localhost.localstack.cloud:4566/my-templates/rds.yml
      Parameters:
        VpcId: !GetAtt VPCStack.Outputs.VpcId
```

```bash
# Upload templates to LocalStack S3
aws --endpoint-url=http://localhost:4566 s3 mb s3://my-templates
aws --endpoint-url=http://localhost:4566 s3 cp vpc-multi-env.yml s3://my-templates/
aws --endpoint-url=http://localhost:4566 s3 cp rds.yml s3://my-templates/

# Deploy parent stack
aws --endpoint-url=http://localhost:4566 cloudformation create-stack \
  --stack-name main-stack \
  --template-body file://main.yml

# Check nested stack resources
aws --endpoint-url=http://localhost:4566 cloudformation list-stack-resources \
  --stack-name main-stack
```

---

## Day 11 - Rewrite infrastructure in Terraform with LocalStack provider, create modules

```hcl
# provider.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    ec2 = "http://localhost:4566"
    s3  = "http://localhost:4566"
    rds = "http://localhost:4566"
  }
}
```

```hcl
# modules/vpc/main.tf
variable "cidr_block" {}
variable "env" {}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = { Name = "${var.env}-vpc" }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.cidr_block, 8, 1)
}

output "vpc_id" {
  value = aws_vpc.main.id
}
```

```hcl
# main.tf - call the module
module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  env        = "dev"
}
```

```bash
# Init and apply
terraform init
terraform plan
terraform apply -auto-approve

# Verify resources on LocalStack
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs

# Destroy
terraform destroy -auto-approve
```

---
