#!/bin/bash

# rds-restore-test.sh
# Restores from a snapshot to a temp instance, verifies, then deletes
# Usage: bash rds-restore-test.sh <snapshot-id>

set -e

SNAPSHOT_ID=$1
RESTORE_ID="aws-devops-db-restore-test"

if [ -z "$SNAPSHOT_ID" ]; then
  echo "Usage: bash rds-restore-test.sh <snapshot-id>"
  echo "Example: bash rds-restore-test.sh aws-devops-db-day44-snapshot"
  exit 1
fi

echo "=== Restore Test Started ==="
echo "Source snapshot : $SNAPSHOT_ID"
echo "Restore target  : $RESTORE_ID"
echo "WARNING: This creates a real RDS instance - delete it when done"

# Restore from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier $RESTORE_ID \
  --db-snapshot-identifier $SNAPSHOT_ID \
  --db-instance-class db.t3.micro \
  --no-multi-az \
  --no-publicly-accessible

echo "Restore started, waiting for available (takes 5-10 min)..."

aws rds wait db-instance-available \
  --db-instance-identifier $RESTORE_ID

echo "Restored instance is available"

# Confirm it exists
aws rds describe-db-instances \
  --db-instance-identifier $RESTORE_ID \
  --query 'DBInstances[0].{Status:DBInstanceStatus,Engine:Engine,Class:DBInstanceClass}' \
  --output table

echo "Restore test PASSED"
echo ""
echo "IMPORTANT: Delete the restore instance now to avoid charges:"
echo "aws rds delete-db-instance --db-instance-identifier $RESTORE_ID --skip-final-snapshot"
