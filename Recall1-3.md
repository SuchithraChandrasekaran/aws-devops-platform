# 95-Day Tracker - Days 1 to 3 Command Recall

---

## Day 1 - Install LocalStack, setup GitHub repo, VPC skeleton on LocalStack

```bash
# Run LocalStack
docker run -d -p 4566:4566 localstack/localstack

# Verify LocalStack is up
curl http://localhost:4566/_localstack/health

# Configure AWS CLI to point to LocalStack
aws configure set aws_access_key_id test
aws configure set aws_secret_access_key test
aws configure set region us-east-1

# Create VPC
aws --endpoint-url=http://localhost:4566 ec2 create-vpc --cidr-block 10.0.0.0/16

# Init GitHub repo
git init
git remote add origin https://github.com/<your-username>/<your-repo>.git
git add . && git commit -m "Day 1/95 - LocalStack environment ready"
git push -u origin main
```

---

## Day 2 - Complete VPC on LocalStack (2 subnets, IGW, security groups), create simple Node.js app

```bash
# Create 2 subnets
aws --endpoint-url=http://localhost:4566 ec2 create-subnet \
  --vpc-id <vpc-id> --cidr-block 10.0.1.0/24 --availability-zone us-east-1a

aws --endpoint-url=http://localhost:4566 ec2 create-subnet \
  --vpc-id <vpc-id> --cidr-block 10.0.2.0/24 --availability-zone us-east-1b

# Create and attach Internet Gateway
aws --endpoint-url=http://localhost:4566 ec2 create-internet-gateway
aws --endpoint-url=http://localhost:4566 ec2 attach-internet-gateway \
  --internet-gateway-id <igw-id> --vpc-id <vpc-id>

# Create Security Group
aws --endpoint-url=http://localhost:4566 ec2 create-security-group \
  --group-name my-sg --description "My SG" --vpc-id <vpc-id>

# Allow inbound HTTP
aws --endpoint-url=http://localhost:4566 ec2 authorize-security-group-ingress \
  --group-id <sg-id> --protocol tcp --port 80 --cidr 0.0.0.0/0

# Init Node.js app
mkdir my-app && cd my-app
npm init -y
node -e "require('http').createServer((req,res)=>res.end('Hello')).listen(3000)"
```

---

## Day 3 - Containerize app with Docker, create Dockerfile, test locally

```bash
# Dockerfile
cat <<EOF > Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "app.js"]
EOF

# Build image
docker build -t my-app:latest .

# Run container locally
docker run -d -p 3000:3000 my-app:latest

# Verify it works
curl http://localhost:3000

# Check running containers
docker ps

# View logs
docker logs <container-id>
```

---
