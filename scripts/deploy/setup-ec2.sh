#!/bin/bash

# setup-ec2.sh
# Run once on EC2 to install Nginx
# Usage: bash setup-ec2.sh

set -e

echo "=== EC2 Setup Started ==="

# Verify Docker is running (installed on Day 36 via user_data)
docker --version || {
  echo "Docker not found, installing..."
  sudo yum install -y docker
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -a -G docker ec2-user
}

# Install Nginx
sudo amazon-linux-extras install nginx1 -y 2>/dev/null || sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

echo "Nginx version: $(nginx -v 2>&1)"
echo "=== EC2 Setup Complete ==="
