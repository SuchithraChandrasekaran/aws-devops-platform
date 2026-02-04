#!/bin/bash

# Traffic Switch Script
# Switches NGINX load balancer to new environment

NEW_ENV=${1:-green}
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG_FILE="${PROJECT_ROOT}/applications/sample-app/deploy/blue-green-config.json"
NGINX_CONFIG="${PROJECT_ROOT}/infrastructure/docker/nginx/nginx.conf"

echo "Switching traffic to: ${NEW_ENV}"

# Determine port based on environment
if [ "${NEW_ENV}" = "blue" ]; then
    NEW_PORT=3000
else
    NEW_PORT=3001
fi

# Update NGINX config
cat > ${NGINX_CONFIG} << EOF
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server host.docker.internal:${NEW_PORT};
    }

    server {
        listen 8080;

        location / {
            proxy_pass http://backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }

        location /health {
            proxy_pass http://backend/health;
            proxy_set_header Host \$host;
        }
    }
}
EOF

# Reload NGINX
echo "Reloading NGINX configuration..."
docker exec nginx-lb nginx -s reload 2>/dev/null || {
    echo "NGINX not running, starting it..."
    docker stop nginx-lb 2>/dev/null || true
    docker rm nginx-lb 2>/dev/null || true
    
    docker run -d \
        --name nginx-lb \
        -p 8080:8080 \
        -v ${NGINX_CONFIG}:/etc/nginx/nginx.conf:ro \
        --add-host=host.docker.internal:host-gateway \
        nginx:alpine
}

# Update config file
jq --arg env "${NEW_ENV}" '.nginx.activeEnvironment = $env' ${CONFIG_FILE} > ${CONFIG_FILE}.tmp
mv ${CONFIG_FILE}.tmp ${CONFIG_FILE}

echo "Traffic switched to ${NEW_ENV} successfully"