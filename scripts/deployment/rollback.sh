#!/bin/bash

# Rollback Script
# Switches back to previous environment

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG_FILE="${PROJECT_ROOT}/applications/sample-app/deploy/blue-green-config.json"

CURRENT_ACTIVE=$(jq -r '.nginx.activeEnvironment' ${CONFIG_FILE})

echo "======================================"
echo "Initiating Rollback"
echo "======================================"
echo "Current environment: ${CURRENT_ACTIVE}"

# Determine rollback target
if [ "${CURRENT_ACTIVE}" = "blue" ]; then
	    ROLLBACK_TO="green"
    else
	        ROLLBACK_TO="blue"
fi

echo "Rolling back to: ${ROLLBACK_TO}"

# Switch traffic back
${PROJECT_ROOT}/scripts/deployment/switch-traffic.sh ${ROLLBACK_TO}

echo ""
echo "======================================"
echo "Rollback Complete"
echo "======================================"
echo "Active environment: ${ROLLBACK_TO}"
