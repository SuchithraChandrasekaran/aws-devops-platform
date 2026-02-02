# GitHub Actions Setup Guide

## Overview

This guide covers the GitHub Actions CI/CD pipeline setup for the AWS DevOps Platform project. GitHub Actions automates building, testing, and deploying your Docker containers.

---

## What is GitHub Actions?

GitHub Actions is a CI/CD platform that allows you to automate your build, test, and deployment pipeline. You can create workflows that build and test every pull request to your repository, or deploy merged pull requests to production.

### Key Concepts

- **Workflow**: An automated process defined in YAML
- **Event**: Triggers that start a workflow (push, pull request, etc.)
- **Job**: A set of steps that execute on the same runner
- **Step**: An individual task (run command, action, etc.)
- **Runner**: A server that runs your workflows
- **Action**: A reusable unit of code

---

## Project Workflows

### 1. Docker Build and Test Workflow

**File**: `.github/workflows/docker-build.yml`

**Purpose**: Builds and tests the Docker image on every push to main/develop branches.

**Triggers**:
- Push to `main` or `develop` branches
- Changes to `applications/sample-app/` directory
- Pull requests to `main` branch

**Steps**:
1. Checkout code
2. Set up Docker Buildx
3. Build Docker image
4. Run container health check
5. Test API endpoints
6. Run unit tests inside container
7. Save image as artifact

**Example Run**:
```yaml
- Build Docker image: ~2 minutes
- Run health check: ~30 seconds
- Test endpoints: ~10 seconds
- Run unit tests: ~15 seconds
Total: ~3 minutes
```

### 2. Deploy to LocalStack Workflow

**File**: `.github/workflows/deploy-to-localstack.yml`

**Purpose**: Deploys the Docker container to LocalStack EC2 after successful build.

**Triggers**:
- Completion of "Docker Build and Test" workflow
- Manual trigger (workflow_dispatch)

**Steps**:
1. Set up LocalStack
2. Configure AWS CLI
3. Download Docker image artifact
4. Create EC2 instance
5. Deploy application
6. Run health checks

---

## Directory Structure

```
.github/
└── workflows/
    ├── docker-build.yml           # Build and test workflow
    └── deploy-to-localstack.yml   # Deployment workflow
```

---

## Setup Instructions

### Step 1: Create GitHub Repository

```bash
# Initialize git if not already done
cd ~/aws-devops-platform
git init

# Add remote repository
git remote add origin https://github.com/YOUR_USERNAME/aws-devops-platform.git

# Create .github/workflows directory
mkdir -p .github/workflows

# Copy workflow files
cp <workflow-files> .github/workflows/
```

### Step 2: Commit and Push

```bash
# Stage all files
git add .github/
git add applications/
git add infrastructure/
git add scripts/
git add docs/

# Commit
git commit -m "Day 4/95 - GitHub Actions + LocalStack setup"

# Push to GitHub
git push -u origin main
```

### Step 3: Verify Workflows

1. Go to your repository on GitHub
2. Click on the "Actions" tab
3. You should see your workflows listed
4. Click on a workflow run to see details

---

## Workflow Configuration Details

### Docker Build Workflow

```yaml
name: Docker Build and Test

on:
  push:
    branches: [ main, develop ]
    paths:
      - 'applications/sample-app/**'
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Build Docker image
        run: |
          docker build -t aws-devops-sample-app:latest .
```

### Key Configuration Options

**on.push.paths**: Only trigger when specific files change
```yaml
paths:
  - 'applications/sample-app/**'
  - '.github/workflows/docker-build.yml'
```

**Environment Variables**: Define once, use everywhere
```yaml
env:
  DOCKER_IMAGE: aws-devops-sample-app
  DOCKER_TAG: ${{ github.sha }}
```

**Artifacts**: Share data between jobs
```yaml
- name: Upload Docker image
  uses: actions/upload-artifact@v4
  with:
    name: docker-image
    path: docker-image.tar.gz
```

---

## Environment Variables

### Automatic Variables

GitHub Actions provides several automatic variables:

- `${{ github.sha }}` - The commit SHA
- `${{ github.ref }}` - The branch or tag ref
- `${{ github.repository }}` - Repository name
- `${{ github.actor }}` - Username who triggered
- `${{ github.event_name }}` - Event that triggered

### Custom Variables

Define in workflow:
```yaml
env:
  LOCALSTACK_ENDPOINT: http://localhost:4566
  AWS_REGION: us-east-1
```

Use in steps:
```yaml
- name: Deploy
  run: |
    echo "Deploying to ${{ env.LOCALSTACK_ENDPOINT }}"
```

---

## Secrets Management

### Creating Secrets

1. Go to repository Settings
2. Click "Secrets and variables" → "Actions"
3. Click "New repository secret"
4. Add secret name and value

### Using Secrets

```yaml
- name: Deploy to AWS
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  run: |
    aws s3 ls
```
## Workflow Triggers

### Push Event

```yaml
on:
  push:
    branches:
      - main
      - develop
    paths:
      - 'src/**'
```

### Pull Request Event

```yaml
on:
  pull_request:
    branches:
      - main
    types:
      - opened
      - synchronize
```

### Manual Trigger

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy to'
        required: true
        default: 'development'
```

### Scheduled Runs

```yaml
on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight
```

### Workflow Completion

```yaml
on:
  workflow_run:
    workflows: ["Docker Build"]
    types:
      - completed
```

---

## Job Configuration

### Basic Job

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "Hello World"
```

### Job with Matrix

```yaml
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node: [14, 16, 18]
    steps:
      - run: node --version
```

### Job Dependencies

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Building"
  
  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: echo "Testing"
  
  deploy:
    needs: [build, test]
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploying"
```

---

## Common Actions

### Checkout Code

```yaml
- name: Checkout
  uses: actions/checkout@v4
```

### Setup Node.js

```yaml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '18'
```

### Setup Python

```yaml
- name: Setup Python
  uses: actions/setup-python@v5
  with:
    python-version: '3.11'
```

### Cache Dependencies

```yaml
- name: Cache node modules
  uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

### Upload Artifacts

```yaml
- name: Upload artifact
  uses: actions/upload-artifact@v4
  with:
    name: my-artifact
    path: path/to/artifact
```

### Download Artifacts

```yaml
- name: Download artifact
  uses: actions/download-artifact@v4
  with:
    name: my-artifact
```

---

## Debugging Workflows

### Enable Debug Logging

Add repository secrets:
- `ACTIONS_RUNNER_DEBUG` = `true`
- `ACTIONS_STEP_DEBUG` = `true`

### View Logs

1. Go to Actions tab
2. Click on workflow run
3. Click on job
4. Expand steps to see logs

### Add Debug Output

```yaml
- name: Debug
  run: |
    echo "GitHub SHA: ${{ github.sha }}"
    echo "Repository: ${{ github.repository }}"
    env
```

### Use tmate for SSH Access

```yaml
- name: Setup tmate session
  uses: mxschmitt/action-tmate@v3
```

---

## Best Practices

### 1. Use Specific Action Versions

 Bad:
```yaml
uses: actions/checkout@main
```

 Good:
```yaml
uses: actions/checkout@v4
```

### 2. Use Path Filters

Only run when relevant files change:
```yaml
on:
  push:
    paths:
      - 'src/**'
      - 'package.json'
```

### 3. Use Caching

Speed up workflows by caching dependencies:
```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-npm-${{ hashFiles('package-lock.json') }}
```

### 4. Use Concurrency Control

Prevent multiple runs:
```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

### 5. Use Matrix Strategies

Test against multiple versions:
```yaml
strategy:
  matrix:
    node-version: [14, 16, 18]
```

### 6. Add Status Checks

Require workflows to pass before merging:
1. Settings → Branches
2. Add branch protection rule
3. Require status checks to pass

---

## Troubleshooting

### Workflow Not Triggering

Check:
- Branch name matches trigger
- Path filters are correct
- File is in `.github/workflows/`
- YAML syntax is valid

### Job Failing

1. Check logs in Actions tab
2. Enable debug logging
3. Test commands locally
4. Verify secrets are set

### Permissions Issues

Add permissions to job:
```yaml
jobs:
  deploy:
    permissions:
      contents: read
      packages: write
```

---

## Monitoring and Notifications

### Email Notifications

Automatically enabled for:
- Failed workflow runs
- Workflows you triggered

## Cost and Limits

### Free Tier (Public Repos)

- **Unlimited** minutes for public repositories
- **Storage**: 500 MB
- **Artifacts retention**: 90 days

### Free Tier (Private Repos)

- **2,000** minutes/month
- **500 MB** storage
- **Artifacts retention**: 90 days

### Best Practices for Limits

1. Use path filters to avoid unnecessary runs
2. Cache dependencies
3. Use self-hosted runners for heavy workloads
4. Clean up old artifacts

---

## Day 4 Checklist

- [x] Create `.github/workflows/` directory
- [x] Add `docker-build.yml` workflow
- [x] Add `deploy-to-localstack.yml` workflow
- [x] Push to GitHub
- [x] Verify workflows run successfully
- [x] Test manual workflow trigger
- [x] Review workflow logs
- [x] Add status badge to README

---