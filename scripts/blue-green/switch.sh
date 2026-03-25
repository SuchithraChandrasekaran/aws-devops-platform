#!/bin/bash
TARGET=$1

if [ -z "$TARGET" ]; then
  echo "Usage: $0 blue|green"
  exit 1
fi

if [ "$TARGET" != "blue" ] && [ "$TARGET" != "green" ]; then
  echo "Target must be 'blue' or 'green'"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Switching traffic to: $TARGET"

docker stop nginx-router && docker rm nginx-router

docker run -d \
  --name nginx-router \
  --network blue-green_app-network \
  -p 80:80 \
  -v $SCRIPT_DIR/nginx/nginx-${TARGET}.conf:/etc/nginx/nginx.conf:ro \
  nginx:alpine

sleep 2

echo "Active environment:"
curl -s http://localhost | python3 -m json.tool
