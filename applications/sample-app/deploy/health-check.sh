#!/bin/bash

# Health check script for blue-green deployment
# Usage: ./health-check.sh <container-name> <port>

CONTAINER_NAME=${1:-sample-app-blue}
PORT=${2:-3000}
HEALTH_ENDPOINT="http://localhost:${PORT}/health"
MAX_ATTEMPTS=30
ATTEMPT=0

echo "Starting health check for ${CONTAINER_NAME} on port ${PORT}"

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT + 1))
    echo "Attempt ${ATTEMPT}/${MAX_ATTEMPTS}..."
    
    # Check if container is running
    if ! docker ps | grep -q ${CONTAINER_NAME}; then
        echo "ERROR: Container ${CONTAINER_NAME} is not running"
        exit 1
    fi
    
    # Perform health check
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" ${HEALTH_ENDPOINT} 2>/dev/null)
    
    if [ "$RESPONSE" = "200" ]; then
        echo "SUCCESS: ${CONTAINER_NAME} is healthy"
        
        # Verify response body
        BODY=$(curl -s ${HEALTH_ENDPOINT})
        echo "Health response: ${BODY}"
        
        if echo "$BODY" | grep -q "healthy"; then
            echo "Health check PASSED"
            exit 0
        fi
    fi
    
    echo "Container not ready yet (HTTP ${RESPONSE}), waiting..."
    sleep 5
done

echo "ERROR: Health check failed after ${MAX_ATTEMPTS} attempts"
exit 1