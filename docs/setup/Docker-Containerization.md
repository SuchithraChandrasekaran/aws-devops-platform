# Docker Setup Guide - Day 3

## Overview
This guide covers Docker containerization for the AWS DevOps Platform sample application as part of Day 3 AWS learning.

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Directory Structure](#directory-structure)
3. [Quick Start](#quick-start)
4. [Manual Step-by-Step Guide](#manual-step-by-step-guide)
5. [Docker Commands Reference](#docker-commands-reference)
6. [Troubleshooting](#troubleshooting)
7. [Best Practices](#best-practices)

---

## 1.Prerequisites

### Required Software
- **Docker**: Version 20.x or higher
- **Node.js**: Version 18.x or higher (for local development)
- **Git**: For version control
- **curl** or **wget**: For testing endpoints

### Install Docker

**Ubuntu/Debian:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
# Log out and log back in
```

**Verify Installation:**
```bash
docker --version
docker run hello-world
```

---

## 2.Directory Structure

```
aws-devops-platform/
├── applications/
│   └── sample-app/
│       ├── src/
│       │   └── index.js          # Main application file
│       ├── config/                # Configuration files
│       ├── tests/                 # Test files
│       ├── package.json           # Dependencies
│       ├── Dockerfile             # Docker build instructions
│       ├── .dockerignore          # Files to exclude from build
│       └── README.md
├── configs/
│   └── docker/
│       ├── docker-compose-dev.yml   # Dev environment
│       ├── docker-compose-prod.yml  # Prod environment
│       └── .env.example             # Environment variables template
└── scripts/
    └── daily-tasks/
        └── day-03-docker.sh         # Automated setup script
```

---

## 3. Quick Start

### Option 1: Automated Script (Recommended)

```bash
# Navigate to project root
cd ~/aws-devops-platform

# Run the Day 3 script
./scripts/daily-tasks/day-03-docker.sh
```

This script will:
- Verify Docker installation
- Build the Docker image
- Start the container
- Test all endpoints
- Display useful commands

### Option 2: Docker Compose (Alternative)

```bash
# Using development configuration
cd configs/docker
docker-compose -f docker-compose-dev.yml up -d

# Using production configuration
docker-compose -f docker-compose-prod.yml up -d
```

### Option 3: Manual Commands

```bash
# Navigate to application directory
cd applications/sample-app

# Build the image
docker build -t aws-devops-sample-app:v1 .

# Run the container
docker run -d -p 3000:3000 --name sample-app-dev aws-devops-sample-app:v1
```

---

## 4. Manual Step-by-Step Guide

### Step 1: Navigate to Application Directory

```bash
cd ~/aws-devops-platform/applications/sample-app
```

### Step 2: Review the Dockerfile

```bash
cat Dockerfile
```

The Dockerfile uses a multi-stage build:
- **Stage 1 (Builder)**: Installs all dependencies and runs tests
- **Stage 2 (Production)**: Creates lightweight production image

### Step 3: Review .dockerignore

```bash
cat .dockerignore
```

This file excludes unnecessary files from the Docker build context, reducing image size.

### Step 4: Build Docker Image

```bash
docker build -t aws-devops-sample-app:v1 .
```

**Flags explained:**
- `-t`: Tag the image with a name and version
- `.`: Build context (current directory)

**Expected output:**
```
[+] Building 45.2s (15/15) FINISHED
 => [internal] load build definition from Dockerfile
 => => transferring dockerfile: 1.23kB
 => [internal] load .dockerignore
 ...
 => => naming to docker.io/library/aws-devops-sample-app:v1
```

### Step 5: Verify Image Created

```bash
docker images | grep aws-devops-sample-app
```

**Expected output:**
```
aws-devops-sample-app   v1      abc123def456   2 minutes ago   150MB
```

### Step 6: Run the Container

```bash
docker run -d \
  -p 3000:3000 \
  --name sample-app-dev \
  --restart unless-stopped \
  aws-devops-sample-app:v1
```

**Flags explained:**
- `-d`: Detached mode (run in background)
- `-p 3000:3000`: Port mapping (host:container)
- `--name`: Assign a name to the container
- `--restart unless-stopped`: Restart policy

### Step 7: Check Container Status

```bash
docker ps
```

**Expected output:**
```
CONTAINER ID   IMAGE                       COMMAND                  CREATED         STATUS                   PORTS                    NAMES
abc123def456   aws-devops-sample-app:v1   "docker-entrypoint.s…"   5 seconds ago   Up 4 seconds (healthy)   0.0.0.0:3000->3000/tcp   sample-app-dev
```

### Step 8: View Container Logs

```bash
docker logs sample-app-dev
```

**Expected output:**
```
==================================================
AWS DevOps Platform - Sample Application
==================================================
Day: 3 - Docker Containerization
Environment: production
Server running on port 3000
Health check: http://localhost:3000/health
==================================================
```

### Step 9: Test the Application

**Test Root Endpoint:**
```bash
curl http://localhost:3000
```

**Expected response:**
```json
{
  "message": "Hello from Docker!",
  "day": "3",
  "task": "Containerization complete!",
  "project": "AWS DevOps Platform",
  "environment": "production",
  "timestamp": "2026-01-31T..."
}
```

**Test Health Endpoint:**
```bash
curl http://localhost:3000/health
```

**Expected response:**
```json
{
  "status": "healthy",
  "uptime": 45.678,
  "timestamp": "2026-01-31T..."
}
```

**Test in Browser:**
- Navigate to: `http://localhost:3000`
- Health check: `http://localhost:3000/health`
- API info: `http://localhost:3000/api/info`

### Step 10: Inspect Container

```bash
# View detailed container information
docker inspect sample-app-dev

# View container resource usage
docker stats sample-app-dev

# View container processes
docker top sample-app-dev
```
---
## 5.Docker Commands Reference

### Container Management

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Start a stopped container
docker start sample-app-dev

# Stop a running container
docker stop sample-app-dev

# Restart a container
docker restart sample-app-dev

# Remove a container (must be stopped first)
docker rm sample-app-dev

# Force remove a running container
docker rm -f sample-app-dev

# View container logs
docker logs sample-app-dev

# Follow logs in real-time
docker logs -f sample-app-dev

# View last 50 lines of logs
docker logs --tail 50 sample-app-dev
```

### Image Management

```bash
# List all images
docker images

# Remove an image
docker rmi aws-devops-sample-app:v1

# Remove unused images
docker image prune

# Remove all unused images
docker image prune -a

# View image history
docker history aws-devops-sample-app:v1
```

### Container Interaction

```bash
# Execute a command in running container
docker exec sample-app-dev ls -la

# Access container shell (interactive)
docker exec -it sample-app-dev sh

# Copy file from container to host
docker cp sample-app-dev:/app/src/index.js ./index-from-container.js

# Copy file from host to container
docker cp ./newfile.js sample-app-dev:/app/
```

### System Management

```bash
# View Docker system information
docker info

# View Docker disk usage
docker system df

# Clean up everything (BE CAREFUL!)
docker system prune -a --volumes

# Remove stopped containers
docker container prune

# Remove unused networks
docker network prune

# Remove unused volumes
docker volume prune
```

### Health Checks

```bash
# Check health status
docker ps --format "table {{.Names}}\t{{.Status}}"

# Inspect health check details
docker inspect --format='{{json .State.Health}}' sample-app-dev | python3 -m json.tool
```

---

## 6.Troubleshooting

### Container Won't Start

**Check logs:**
```bash
docker logs sample-app-dev
```

**Common issues:**
- Port 3000 already in use
- Missing dependencies in package.json
- Syntax errors in application code

**Solution:**
```bash
# Use a different port
docker run -d -p 3001:3000 --name sample-app-dev aws-devops-sample-app:v1

# Or find and kill process using port 3000
lsof -ti:3000 | xargs kill -9
```

### Can't Access Application

**Verify container is running:**
```bash
docker ps | grep sample-app-dev
```

**Check port mapping:**
```bash
docker port sample-app-dev
```

**Test from inside container:**
```bash
docker exec sample-app-dev wget -O- http://localhost:3000
```

### Build Fails

**Clear Docker cache:**
```bash
docker builder prune
docker build --no-cache -t aws-devops-sample-app:v1 .
```

**Check .dockerignore:**
Ensure important files aren't being excluded.

### Image Size Too Large

**Use multi-stage builds** (already implemented in our Dockerfile)

**Check image size:**
```bash
docker images aws-devops-sample-app
```

**View layer sizes:**
```bash
docker history aws-devops-sample-app:v1
```

### Permission Denied

**Add user to docker group:**
```bash
sudo usermod -aG docker $USER
# Log out and log back in
```

**Or use sudo:**
```bash
sudo docker ps
```

---

## 7. Best Practices

### 1. Use Multi-Stage Builds
Implemented in our Dockerfile - reduces final image size

### 2. Use .dockerignore
Implemented - excludes node_modules, tests, documentation

### 3. Run as Non-Root User
Implemented - container runs as user `nodejs` (UID 1001)

### 4. Implement Health Checks
Implemented - checks `/health` endpoint every 30 seconds

### 5. Use Specific Base Image Tags
Using `node:18-alpine` instead of `node:latest`

### 6. Minimize Layers
Combining commands with `&&` where appropriate

### 7. Label Your Images
Added labels for maintainer, version, description

### 8. Set Resource Limits
```bash
docker run -d \
  -p 3000:3000 \
  --memory="512m" \
  --cpus="1" \
  --name sample-app-dev \
  aws-devops-sample-app:v1
```

### 9. Use Environment Variables
```bash
docker run -d \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e PORT=3000 \
  --name sample-app-dev \
  aws-devops-sample-app:v1
```

### 10. Regular Security Scans
```bash
# Install Trivy
# Then scan your image
trivy image aws-devops-sample-app:v1
```

---
## Resources

- **Official Docker Docs**: https://docs.docker.com/
- **Docker Hub**: https://hub.docker.com/
- **Node.js Docker Best Practices**: https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md
- **Docker Security**: https://docs.docker.com/engine/security/

---

## Git Commit Message

```
Day 3 - Application containerized

- Created Dockerfile with multi-stage build for optimization
- Implemented .dockerignore to reduce build context
- Built Docker image: aws-devops-sample-app:v1
- Configured production and development docker-compose files
- Added health checks and non-root user security
- Tested container locally on port 3000
- Verified all endpoints: /, /health, /api/info, /ready
- Created automated deployment script
- Size: 150MB (Alpine-based)

Technical details:
- Base image: node:18-alpine
- Security: Non-root user (nodejs:1001)
- Health check: 30s interval
- Resource limits: 512M memory, 1 CPU
- Restart policy: unless-stopped

```
---
