# Days 4 to 8 Command Recall

---

## Day 4 - Deploy container to LocalStack EC2, setup basic GitHub Actions pipeline

```bash
# Deploy container to LocalStack EC2
aws --endpoint-url=http://localhost:4566 ec2 run-instances \
  --image-id ami-000001 \
  --instance-type t3.micro \
  --subnet-id <subnet-id> \
  --security-group-ids <sg-id> \
  --count 1

# Verify instance running
aws --endpoint-url=http://localhost:4566 ec2 describe-instances

# .github/workflows/deploy.yml - basic GitHub Actions pipeline
cat <<EOF > .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker image
        run: docker build -t my-app:latest .
      - name: Deploy to LocalStack
        run: echo "Deploy step here"
EOF
```

---

## Day 5 - Build pipeline: GitHub → GitHub Actions → Docker → LocalStack S3

```bash
# Create S3 bucket on LocalStack
aws --endpoint-url=http://localhost:4566 s3 mb s3://my-app-artifacts

# Build and push Docker image artifact to S3
docker build -t my-app:latest .
docker save my-app:latest | gzip > my-app.tar.gz
aws --endpoint-url=http://localhost:4566 s3 cp my-app.tar.gz s3://my-app-artifacts/

# Verify upload
aws --endpoint-url=http://localhost:4566 s3 ls s3://my-app-artifacts/

# GitHub Actions step to upload artifact
cat <<EOF >> .github/workflows/deploy.yml
      - name: Upload artifact to LocalStack S3
        run: |
          docker save my-app:latest | gzip > my-app.tar.gz
          aws --endpoint-url=http://localhost:4566 s3 cp my-app.tar.gz s3://my-app-artifacts/
        env:
          AWS_ACCESS_KEY_ID: test
          AWS_SECRET_ACCESS_KEY: test
          AWS_DEFAULT_REGION: us-east-1
EOF
```

---

## Day 6 - Add automated tests to pipeline (Jest/Pytest), integrate Trivy security scanning

```bash
# Install Jest
npm install --save-dev jest

# Run Jest tests
npx jest

# Install Pytest
pip install pytest

# Run Pytest
pytest tests/

# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh

# Scan Docker image with Trivy
trivy image my-app:latest

# Fail build if critical vulnerabilities found
trivy image --exit-code 1 --severity CRITICAL my-app:latest

# Add to GitHub Actions pipeline
cat <<EOF >> .github/workflows/deploy.yml
      - name: Run tests
        run: npx jest
      - name: Trivy scan
        run: trivy image --exit-code 1 --severity CRITICAL my-app:latest
EOF
```

---

## Day 7 - Blue-green deployment simulation with Docker, Week 1 sprint review

```bash
# Run Blue environment (current live)
docker run -d --name blue -p 3000:3000 my-app:v1

# Run Green environment (new version)
docker run -d --name green -p 3001:3000 my-app:v2

# Verify both are running
docker ps

# Test green before switching
curl http://localhost:3001

# Switch traffic: stop blue, expose green on port 3000
docker stop blue
docker rm blue
docker run -d --name blue -p 3000:3000 my-app:v2

# Rollback if needed: bring back old blue
docker stop blue
docker run -d --name blue -p 3000:3000 my-app:v1
```

---

## Day 8 - Convert VPC to CloudFormation template, deploy on LocalStack

```bash
# vpc.yml - CloudFormation template
cat <<EOF > vpc.yml
AWSTemplateFormatVersion: '2010-09-09'
Resources:
  MyVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
  MySubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MyVPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: us-east-1a
  MySubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MyVPC
      CidrBlock: 10.0.2.0/24
      AvailabilityZone: us-east-1b
  MyIGW:
    Type: AWS::EC2::InternetGateway
  AttachIGW:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref MyVPC
      InternetGatewayId: !Ref MyIGW
EOF

# Deploy stack on LocalStack
aws --endpoint-url=http://localhost:4566 cloudformation create-stack \
  --stack-name my-vpc-stack \
  --template-body file://vpc.yml

# Check stack status
aws --endpoint-url=http://localhost:4566 cloudformation describe-stacks \
  --stack-name my-vpc-stack

# List stack resources
aws --endpoint-url=http://localhost:4566 cloudformation list-stack-resources \
  --stack-name my-vpc-stack
```

---
