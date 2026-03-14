#!/bin/bash

# rds-snapshot.sh
# Takes a manual RDS snapshot and cleans up old ones
# Usage: bash rds-snapshot.sh

set -e

DB_IDENTIFIER="aws-devops-db"
RETENTION_DAYS=7
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SNAPSHOT_ID="${DB_IDENTIFIER}-manual-${TIMESTAMP}"

echo "=== RDS Snapshot Started ==="
echo "DB: $DB_IDENTIFIER"
echo "Snapshot ID: $SNAPSHOT_ID"

# Check DB is available
STATUS=$(aws rds describe-db-instances \
  --db-instance-identifier $DB_IDENTIFIER \
  --query 'DBInstances[0].DBInstanceStatus' \
  --output text)

if [ "$STATUS" != "available" ]; then
  echo "DB status is $STATUS - must be available to snapshot"
  exit 1
fi

# Take snapshot
aws rds create-db-snapshot \
  --db-instance-identifier $DB_IDENTIFIER \
  --db-snapshot-identifier $SNAPSHOT_ID

echo "Snapshot $SNAPSHOT_ID created, waiting for completion..."

aws rds wait db-snapshot-completed \
  --db-snapshot-identifier $SNAPSHOT_ID

echo "Snapshot complete"

# Clean up manual snapshots older than retention days
echo "Cleaning up snapshots older than $RETENTION_DAYS days..."
CUTOFF_DATE=$(date -d "-${RETENTION_DAYS} days" +%Y-%m-%dT%H:%M:%S 2>/dev/null || \
              date -v -${RETENTION_DAYS}d +%Y-%m-%dT%H:%M:%S)

aws rds describe-db-snapshots \
  --db-instance-identifier $DB_IDENTIFIER \
  --snapshot-type manual \
  --query "DBSnapshots[?SnapshotCreateTime<='${CUTOFF_DATE}'].DBSnapshotIdentifier" \
  --output text | tr '\t' '\n' | while read snapshot; do
    if [ -n "$snapshot" ]; then
      echo "Deleting old snapshot: $snapshot"
      aws rds delete-db-snapshot --db-snapshot-identifier "$snapshot"
    fi
done

echo "=== RDS Snapshot Complete ==="
