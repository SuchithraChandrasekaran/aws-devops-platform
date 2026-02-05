#!/bin/bash

# Cleanup Script
# Removes inactive environment after successful deployment

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG_FILE="${PROJECT_ROOT}/applications/sample-app/deploy/blue-green-config.json"

CURRENT_ACTIVE=$(jq -r '.nginx.activeEnvironment' ${CONFIG_FILE})

if [ "${CURRENT_ACTIVE}" = "blue" ]; then
    OLD_CONTAINER="sample-app-green"
    OLD_ENV="green"
else
    OLD_CONTAINER="sample-app-blue"
    OLD_ENV="blue"
fi

echo "Cleaning up inactive environment: ${OLD_ENV}"
echo "Removing container: ${OLD_CONTAINER}"

docker stop ${OLD_CONTAINER} 2>/dev/null || echo "Container already stopped"
docker rm ${OLD_CONTAINER} 2>/dev/null || echo "Container already removed"

echo "Cleanup complete"