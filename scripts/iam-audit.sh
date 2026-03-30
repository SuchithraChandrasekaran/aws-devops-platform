#!/bin/bash
# IAM Audit Script
# Usage: ./scripts/iam-audit.sh
# Checks: stale credentials, missing MFA, admin access, wildcard policies, unused roles

REGION="us-east-1"
STALE_DAYS=90
ISSUES=0

echo "========================================"
echo "IAM Audit - $(date)"
echo "========================================"

# ── 1. Check for access keys older than STALE_DAYS ──────────────────────────
echo ""
echo "--- Checking for stale access keys (>${STALE_DAYS} days) ---"
CUTOFF=$(date -d "-${STALE_DAYS} days" +%Y-%m-%d 2>/dev/null || date -v-${STALE_DAYS}d +%Y-%m-%d)

aws iam list-users --query 'Users[*].UserName' --output text | tr '\t' '\n' | while read USER; do
  aws iam list-access-keys --user-name "$USER" \
    --query 'AccessKeyMetadata[*].[AccessKeyId,Status,CreateDate]' \
    --output text | while read KEY_ID STATUS CREATE_DATE; do
      CREATE_DAY=$(echo "$CREATE_DATE" | cut -c1-10)
      if [[ "$CREATE_DAY" < "$CUTOFF" ]] && [ "$STATUS" = "Active" ]; then
        echo "WARNING: $USER - key $KEY_ID active since $CREATE_DAY (>${STALE_DAYS} days)"
        ISSUES=$((ISSUES+1))
      fi
  done
done

# ── 2. Check for console users without MFA ───────────────────────────────────
echo ""
echo "--- Checking for console access without MFA ---"
aws iam list-users --query 'Users[*].UserName' --output text | tr '\t' '\n' | while read USER; do
  HAS_PASS=$(aws iam get-login-profile --user-name "$USER" 2>/dev/null && echo "true" || echo "false")
  if [ "$HAS_PASS" = "true" ]; then
    MFA_COUNT=$(aws iam list-mfa-devices --user-name "$USER" --query 'length(MFADevices)')
    if [ "$MFA_COUNT" = "0" ]; then
      echo "CRITICAL: $USER has console access but NO MFA"
      ISSUES=$((ISSUES+1))
    fi
  fi
done

# ── 3. Check for AdministratorAccess on roles ────────────────────────────────
echo ""
echo "--- Checking for AdministratorAccess on roles ---"
aws iam list-roles --query 'Roles[*].RoleName' --output text | tr '\t' '\n' | while read ROLE; do
  ATTACHED=$(aws iam list-attached-role-policies --role-name "$ROLE" \
    --query 'AttachedPolicies[?PolicyName==`AdministratorAccess`].PolicyName' \
    --output text 2>/dev/null)
  if [ ! -z "$ATTACHED" ]; then
    echo "WARNING: Role $ROLE has AdministratorAccess - review if needed"
    ISSUES=$((ISSUES+1))
  fi
done

# ── 4. Check customer-managed policies for wildcard actions ──────────────────
echo ""
echo "--- Checking customer-managed policies for wildcard actions ---"
aws iam list-policies --scope Local \
  --query 'Policies[*].[PolicyName,Arn,DefaultVersionId]' \
  --output text | while read NAME ARN VERSION; do
    DOC=$(aws iam get-policy-version \
      --policy-arn "$ARN" --version-id "$VERSION" \
      --query 'PolicyVersion.Document' --output json 2>/dev/null)
    if echo "$DOC" | grep -q '"Action": "\*"'; then
      echo "WARNING: Policy $NAME has Action: '*' - tighten to specific actions"
      ISSUES=$((ISSUES+1))
    fi
done

# ── 5. Check for roles not used in 90 days ───────────────────────────────────
echo ""
echo "--- Checking role last activity ---"
aws iam list-roles --query 'Roles[*].RoleName' --output text | tr '\t' '\n' | \
  grep -v '^AWS\|^aws' | while read ROLE; do
    LAST_USED=$(aws iam get-role --role-name "$ROLE" \
      --query 'Role.RoleLastUsed.LastUsedDate' --output text 2>/dev/null)
    if [ "$LAST_USED" = "None" ] || [ -z "$LAST_USED" ]; then
      echo "INFO: $ROLE - never used (consider deleting if not needed)"
    fi
done

echo ""
echo "========================================"
echo "Audit complete"
echo "========================================"
