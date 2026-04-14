# Days 35 to 37 Command Recall

---

## Day 35 - Complete integration testing of all LocalStack components, end-to-end testing

```bash
# Verify all LocalStack services are healthy
curl http://localhost:4566/_localstack/health | jq .

# End-to-end test: full pipeline flow
# 1. Push code → GitHub Actions builds image
git commit -m "test: trigger e2e" && git push

# 2. Verify S3 artifact uploaded
aws --endpoint-url=http://localhost:4566 s3 ls s3://my-app-artifacts/

# 3. Verify EC2 instance running
aws --endpoint-url=http://localhost:4566 ec2 describe-instances \
  --filters Name=instance-state-name,Values=running

# 4. Verify CloudWatch metrics flowing
aws --endpoint-url=http://localhost:4566 cloudwatch list-metrics --namespace "MyApp"

# 5. Verify SNS/SQS fan-out
aws --endpoint-url=http://localhost:4566 sns publish \
  --topic-arn arn:aws:sns:us-east-1:000000000000:app-events \
  --message '{"event": "e2e_test"}'

aws --endpoint-url=http://localhost:4566 sqs receive-message \
  --queue-url http://localhost:4566/000000000000/orders-queue

# 6. Verify EventBridge rules firing
aws --endpoint-url=http://localhost:4566 events put-events \
  --entries '[{
    "Source": "myapp.monitoring",
    "DetailType": "MetricAlarm",
    "Detail": "{\"alarmName\": \"HighCPU\", \"state\": \"ALARM\"}",
    "EventBusName": "remediation-bus"
  }]'

# 7. Verify Lambda executions
aws --endpoint-url=http://localhost:4566 lambda list-functions --query 'Functions[].FunctionName'

aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name health-check --payload '{}' response.json && cat response.json

# 8. Verify SSM parameters
aws --endpoint-url=http://localhost:4566 ssm get-parameters-by-path \
  --path "/myapp/dev" --with-decryption

# 9. Verify Step Functions
aws --endpoint-url=http://localhost:4566 stepfunctions list-state-machines

# 10. Verify Config compliance
aws --endpoint-url=http://localhost:4566 configservice describe-compliance-by-config-rule

# Full stack summary check
echo "=== EC2 ===" && aws --endpoint-url=http://localhost:4566 ec2 describe-instances --query 'Reservations[].Instances[].{ID:InstanceId,State:State.Name}'
echo "=== S3 ===" && aws --endpoint-url=http://localhost:4566 s3 ls
echo "=== Lambdas ===" && aws --endpoint-url=http://localhost:4566 lambda list-functions --query 'Functions[].FunctionName'
echo "=== Alarms ===" && aws --endpoint-url=http://localhost:4566 cloudwatch describe-alarms --query 'MetricAlarms[].{Name:AlarmName,State:StateValue}'
```

---

## Day 36 - Deploy base infrastructure to AWS Free Tier (VPC, EC2 t2.micro, Security Groups). Set billing alarm at $1

```bash
# Configure real AWS CLI (not LocalStack)
aws configure
# Enter: Access Key, Secret Key, region: us-east-1, output: json

# Set billing alarm FIRST before anything else
aws cloudwatch put-metric-alarm \
  --alarm-name "BillingAlarm-1USD" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 86400 \
  --threshold 1 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:us-east-1:<account-id>:my-alerts \
  --dimensions Name=Currency,Value=USD

# Create VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16 \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=myapp-vpc}]'

# Create subnet
aws ec2 create-subnet \
  --vpc-id <vpc-id> --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a

# Create and attach Internet Gateway
aws ec2 create-internet-gateway
aws ec2 attach-internet-gateway --internet-gateway-id <igw-id> --vpc-id <vpc-id>

# Create route table and add public route
aws ec2 create-route-table --vpc-id <vpc-id>
aws ec2 create-route \
  --route-table-id <rtb-id> \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id <igw-id>
aws ec2 associate-route-table --route-table-id <rtb-id> --subnet-id <subnet-id>

# Create Security Group
aws ec2 create-security-group \
  --group-name myapp-sg \
  --description "MyApp SG" \
  --vpc-id <vpc-id>

# Allow SSH and HTTP only
aws ec2 authorize-security-group-ingress \
  --group-id <sg-id> --protocol tcp --port 22 --cidr <ip>/32

aws ec2 authorize-security-group-ingress \
  --group-id <sg-id> --protocol tcp --port 80 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-id <sg-id> --protocol tcp --port 443 --cidr 0.0.0.0/0

# Launch t2.micro (Free Tier)
aws ec2 run-instances \
  --image-id ami-0c02fb55956c7d316 \
  --instance-type t2.micro \
  --subnet-id <subnet-id> \
  --security-group-ids <sg-id> \
  --associate-public-ip-address \
  --key-name <key-pair> \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=myapp-server}]'

# Verify instance public IP
aws ec2 describe-instances \
  --filters Name=tag:Name,Values=myapp-server \
  --query 'Reservations[].Instances[].{ID:InstanceId,IP:PublicIpAddress,State:State.Name}'
```

---

## Day 37 - Deploy application to real AWS EC2 via GitHub Actions, configure NGINX reverse proxy

```bash
# SSH into EC2
ssh -i <key.pem> ec2-user@<public-ip>

# On EC2: install Docker and NGINX
sudo yum update -y
sudo yum install -y docker nginx
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# On EC2: install NGINX
sudo systemctl start nginx
sudo systemctl enable nginx
```

```nginx
# /etc/nginx/conf.d/myapp.conf
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# On EC2: apply NGINX config
sudo nginx -t
sudo systemctl reload nginx
```

```yaml
# .github/workflows/deploy-aws.yml
name: Deploy to AWS EC2
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

      - name: Copy image to EC2
        uses: appleboy/scp-action@master
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ec2-user
          key: ${{ secrets.EC2_SSH_KEY }}
          source: "."
          target: "/home/ec2-user/app"

      - name: Deploy on EC2
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ec2-user
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            cd /home/ec2-user/app
            docker build -t my-app:latest .
            docker stop myapp || true
            docker rm myapp || true
            docker run -d --name myapp -p 3000:3000 my-app:latest
            sudo systemctl reload nginx
```

```bash
# Add GitHub secrets
# EC2_HOST =  EC2 public IP
# EC2_SSH_KEY = contents of  .pem file

# Verify deployment
curl http://<ec2-public-ip>

# Check NGINX logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Check app container
docker ps
docker logs myapp
```

---
