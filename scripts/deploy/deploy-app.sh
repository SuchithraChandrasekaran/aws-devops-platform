#!/bin/bash

# deploy-app.sh
# Called by GitHub Actions on every push to main
# Runs on EC2 via SSH

set -e

echo "=== Deployment Started ==="
echo "Timestamp: $(date)"

APP_NAME="sample-app"
APP_PORT=3000
IMAGE_NAME="sample-app:latest"

# Stop and remove old container if running
if docker ps -a --format '{{.Names}}' | grep -q "^${APP_NAME}$"; then
  echo "Stopping old container..."
  docker stop $APP_NAME || true
  docker rm $APP_NAME || true
fi

# Load the new image
echo "Loading Docker image..."
docker load < /tmp/sample-app.tar.gz

# Start new container
echo "Starting new container..."
docker run -d \
  --name $APP_NAME \
  --restart unless-stopped \
  -p $APP_PORT:$APP_PORT \
  -e NODE_ENV=production \
  $IMAGE_NAME

# Wait for app to start
sleep 5

# Health check direct to app
echo "Checking app health..."
curl -f http://localhost:$APP_PORT/health || {
  echo "App health check failed"
  docker logs $APP_NAME
  exit 1
}

# Copy and apply Nginx config
echo "Configuring Nginx..."
sudo cp /tmp/nginx.conf /etc/nginx/nginx.conf
sudo nginx -t || {
  echo "Nginx config test failed"
  exit 1
}
sudo systemctl restart nginx

# Final check through Nginx
sleep 2
curl -f http://localhost/health || {
  echo "Nginx health check failed"
  exit 1
}

echo "=== Deployment Complete ==="
echo "App running at http://$(curl -s ifconfig.me)"
