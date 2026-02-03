# S3 Artifacts Storage Guide

## Overview

This guide covers the S3-based artifact storage system for the CI/CD pipeline. Artifacts include Docker images, build logs, and deployment metadata.

---

## S3 Bucket Structure

aws-devops-artifacts/
├── docker-images/
│   ├── aws-devops-sample-app-20260202-120000-abc1234.tar.gz
│   ├── aws-devops-sample-app-20260202-130000-def5678.tar.gz
│   └── ...
└── metadata/
├── aws-devops-sample-app-20260202-120000-abc1234.json
├── aws-devops-sample-app-20260202-130000-def5678.json
└── ...
aws-devops-pipeline-logs/
├── build-logs/
├── test-logs/
└── deployment-logs/

---

## Artifact Naming Convention

Format: `{app-name}-{timestamp}-{git-sha}.tar.gz`

Example: `aws-devops-sample-app-20260202-143022-a1b2c3d.tar.gz`

- **app-name**: Application identifier
- **timestamp**: YYYYMMDD-HHMMSS format
- **git-sha**: Short Git commit hash

---

## Artifact Metadata

Each artifact has associated metadata in JSON format:
```json
{
  "image_name": "aws-devops-sample-app",
  "version": "20260202-143022-a1b2c3d",
  "git_sha": "a1b2c3d",
  "timestamp": "20260202-143022",
  "build_date": "2026-02-02T14:30:22Z",
  "size_bytes": 52428800,
  "branch": "main",
  "tags": ["latest", "dev"]
}
```

---

## Common Commands

### List all artifacts
```bash
aws --endpoint-url=http://localhost:4566 --profile localstack \
    s3 ls s3://aws-devops-artifacts/docker-images/
```

### Upload artifact
```bash
aws --endpoint-url=http://localhost:4566 --profile localstack \
    s3 cp docker-image.tar.gz \
    s3://aws-devops-artifacts/docker-images/
```

### Download artifact
```bash
aws --endpoint-url=http://localhost:4566 --profile localstack \
    s3 cp s3://aws-devops-artifacts/docker-images/IMAGE.tar.gz .
```

### Delete old artifacts
```bash
./scripts/pipeline/cleanup-old-artifacts.sh
```

---

## Lifecycle Management

Artifacts are automatically cleaned up based on:
- **Age**: Versions older than 30 days are deleted
- **Count**: Keep last 5 versions per application
- **Manual**: Run cleanup script when needed

---

## Best Practices

1. **Always version artifacts** - Never overwrite existing artifacts
2. **Include metadata** - Store build information with each artifact
3. **Tag appropriately** - Use semantic versioning or date-based versions
4. **Clean up regularly** - Run cleanup scripts to manage storage
5. **Monitor storage** - Check S3 bucket sizes periodically

---

## Troubleshooting

### Artifact not found
```bash
# List all artifacts
aws --endpoint-url=http://localhost:4566 --profile localstack \
    s3 ls s3://aws-devops-artifacts/docker-images/
```

### Upload failed
```bash
# Check bucket exists
aws --endpoint-url=http://localhost:4566 --profile localstack \
    s3 ls s3://aws-devops-artifacts/
```

### Storage full (LocalStack)
```bash
# Run cleanup
./scripts/pipeline/cleanup-old-artifacts.sh
```

---
**Storage**: S3 Artifacts