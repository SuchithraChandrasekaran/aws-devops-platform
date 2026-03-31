#!/bin/bash
# DR Script: Recover S3 object or enable versioning
# Usage: ./scripts/dr/recover-s3.sh <BUCKET_NAME> [OBJECT_KEY]

set -e

BUCKET="${1:?Usage: $0 <BUCKET_NAME> [OBJECT_KEY]}"
OBJECT_KEY="$2"
REGION="us-east-1"

echo "========================================"
echo "S3 Recovery Check - $(date)"
echo "Bucket: $BUCKET"
echo "========================================"

# Check versioning status
VERSIONING=$(aws s3api get-bucket-versioning \
  --bucket "$BUCKET" \
  --query 'Status' \
  --output text 2>/dev/null || echo "None")

echo "Versioning status: $VERSIONING"

if [ "$VERSIONING" != "Enabled" ]; then
  echo ""
  echo "WARNING: Versioning is not enabled on $BUCKET"
  read -p "Enable versioning now? (yes/no): " ENABLE
  if [ "$ENABLE" = "yes" ]; then
    aws s3api put-bucket-versioning \
      --bucket "$BUCKET" \
      --versioning-configuration Status=Enabled
    echo "Versioning enabled. Future objects will be versioned."
    echo "NOTE: Existing objects already deleted cannot be recovered."
  fi
fi

# If an object key was provided, attempt recovery
if [ ! -z "$OBJECT_KEY" ]; then
  echo ""
  echo "--- Recovering: $OBJECT_KEY ---"

  # List all versions of this object
  echo "Available versions:"
  aws s3api list-object-versions \
    --bucket "$BUCKET" \
    --prefix "$OBJECT_KEY" \
    --query 'Versions[*].[VersionId,LastModified,IsLatest]' \
    --output table 2>/dev/null

  # Find and remove the delete marker (restores the object)
  DELETE_MARKER=$(aws s3api list-object-versions \
    --bucket "$BUCKET" \
    --prefix "$OBJECT_KEY" \
    --query 'DeleteMarkers[?IsLatest==`true`].VersionId' \
    --output text 2>/dev/null)

  if [ ! -z "$DELETE_MARKER" ] && [ "$DELETE_MARKER" != "None" ]; then
    echo "Delete marker found: $DELETE_MARKER"
    read -p "Remove delete marker to restore object? (yes/no): " RESTORE
    if [ "$RESTORE" = "yes" ]; then
      aws s3api delete-object \
        --bucket "$BUCKET" \
        --key "$OBJECT_KEY" \
        --version-id "$DELETE_MARKER"
      echo "Delete marker removed — object restored."
    fi
  else
    echo "No delete marker found. Object may still exist or was never versioned."
  fi
fi

echo ""
echo "========================================"
echo "S3 check complete"
echo "========================================"
