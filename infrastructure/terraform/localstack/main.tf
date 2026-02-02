# AWS DevOps Platform - Day 4
# Terraform Configuration for LocalStack EC2
# Location: infrastructure/terraform/localstack/main.tf

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider configuration for LocalStack
provider "aws" {
  region                      = var.aws_region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2            = var.localstack_endpoint
    s3             = var.localstack_endpoint
    dynamodb       = var.localstack_endpoint
    cloudformation = var.localstack_endpoint
    cloudwatch     = var.localstack_endpoint
    iam            = var.localstack_endpoint
    lambda         = var.localstack_endpoint
    sns            = var.localstack_endpoint
    sqs            = var.localstack_endpoint
  }
}

# Data source for Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group
resource "aws_security_group" "app_sg" {
  name        = var.security_group_name
  description = "Security group for AWS DevOps sample application"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Application Port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = var.security_group_name
    Environment = var.environment
    Project     = var.project_name
    Day         = "4"
    ManagedBy   = "Terraform"
  }
}

# Key Pair
resource "aws_key_pair" "app_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)

  tags = {
    Name        = var.key_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.app_key.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              service docker start
              usermod -a -G docker ec2-user
              
              # Pull and run the application (if image is available)
              docker pull ${var.docker_image}:${var.docker_tag} || echo "Image not available yet"
              
              # Run container if pull was successful
              if docker images | grep -q ${var.docker_image}; then
                docker run -d \
                  --name ${var.container_name} \
                  -p 80:3000 \
                  -p 3000:3000 \
                  --restart unless-stopped \
                  ${var.docker_image}:${var.docker_tag}
              fi
              EOF

  tags = {
    Name        = var.instance_name
    Environment = var.environment
    Project     = var.project_name
    Day         = "4"
    ManagedBy   = "Terraform"
    Application = "sample-app"
  }
}

# Elastic IP (optional, for static IP)
resource "aws_eip" "app_eip" {
  count    = var.allocate_elastic_ip ? 1 : 0
  instance = aws_instance.app_server.id

  tags = {
    Name        = "${var.instance_name}-eip"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
