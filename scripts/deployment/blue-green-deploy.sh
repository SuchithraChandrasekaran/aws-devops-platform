#!/bin/bash

# Blue-Green Deployment Orchestrator
# This script manages the complete blue-green deployment process

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG_FILE="${PROJECT_ROOT}/applications/sample-app/deploy/blue-green-config.json"

echo "======================================"
echo "Blue-Green Deployment Starting"
echo "======================================"

# Load configuration
BLUE_PORT=$(jq -r '.deployment.bluePort' ${CONFIG_FILE})
GREEN_PORT=$(jq -r '.deployment.greenPort' ${CONFIG_FILE})
NGINX_PORT=$(jq -r '.deployment.nginxPort' ${CONFIG_FILE})
CURRENT_ACTIVE=$(jq -r '.nginx.activeEnvironment' ${CONFIG_FILE})

echo "Current active environment: ${CURRENT_ACTIVE}"

# Determine new environment
if [ "${CURRENT_ACTIVE}" = "blue" ]; then
    NEW_ENV="green"
    NEW_PORT=${GREEN_PORT}
    NEW_CONTAINER="sample-app-green"
    OLD_ENV="blue"
    OLD_CONTAINER="sample-app-blue"
else
    NEW_ENV="blue"
    NEW_PORT=${BLUE_PORT}
    NEW_CONTAINER="sample-app-blue"
    OLD_ENV="green"
    OLD_CONTAINER="sample-app-green"
fi

echo "Deploying to: ${NEW_ENV} environment (port ${NEW_PORT})"

# Step 1: Build new version
echo ""
echo "Step 1: Building new version..."
docker build -t sample-app:${NEW_ENV} ${PROJECT_ROOT}/applications/sample-app/

# Step 2: Stop old new environment container if running
echo ""
echo "Step 2: Stopping old ${NEW_ENV} container if exists..."
docker stop ${NEW_CONTAINER} 2>/dev/null || true
docker rm ${NEW_CONTAINER} 2>/dev/null || true

# Step 3: Start new environment container
echo ""
echo "Step 3: Starting ${NEW_ENV} container..."
docker run -d \
    --name ${NEW_CONTAINER} \
    -p ${NEW_PORT}:3000 \
    -e PORT=3000 \
     sample-app:${NEW_ENV}

# Step 4: Health check
echo ""
echo "Step 4: Running health checks..."
if ! ${PROJECT_ROOT}/applications/sample-app/deploy/health-check.sh ${NEW_CONTAINER} ${NEW_PORT}; then
    echo "ERROR: Health check failed, rolling back..."
    docker stop ${NEW_CONTAINER}
    docker rm ${NEW_CONTAINER}
    exit 1
fi

# Step 5: Switch traffic
echo ""
echo "Step 5: Switching traffic to ${NEW_ENV}..."
${PROJECT_ROOT}/scripts/deployment/switch-traffic.sh ${NEW_ENV}

# Step 6: Final verification
echo ""
echo "Step 6: Final verification via load balancer..."
sleep 5
RESPONSE=$(curl -s http://localhost:${NGINX_PORT}/health)
if echo "$RESPONSE" | grep -q "healthy"; then
    echo "SUCCESS: Traffic switched successfully"
else
    echo "ERROR: Traffic switch verification failed"
    ${PROJECT_ROOT}/scripts/deployment/rollback.sh
    exit 1
fi

# Step 7: Cleanup old environment (optional)
echo ""
echo "Step 7: Old ${OLD_ENV} environment still running for safety"
echo "To remove: docker stop ${OLD_CONTAINER} && docker rm ${OLD_CONTAINER}"

echo ""
echo "======================================"
echo "Blue-Green Deployment Complete!"
echo "======================================"
echo "Active environment: ${NEW_ENV}"
echo "Accessible at: http://localhost:${NGINX_PORT}"
