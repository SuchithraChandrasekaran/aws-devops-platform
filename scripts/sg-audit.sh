#!/bin/bash
# Security Group Audit Script
# Usage: ./scripts/sg-audit.sh
# Checks for: open 0.0.0.0/0 rules, SSH/RDP exposure, all-traffic rules

REGION="us-east-1"
ISSUES=0

echo "========================================"
echo "Security Group Audit - $(date)"
echo "========================================"

# Get all security groups
SG_DATA=$(aws ec2 describe-security-groups \
  --region $REGION \
  --output json)

echo ""
echo "--- Checking for dangerous inbound rules ---"

echo "$SG_DATA" | python3 -c "
import json, sys

data = json.load(sys.stdin)
issues = 0

SENSITIVE_PORTS = {22: 'SSH', 3389: 'RDP', 3306: 'MySQL', 5432: 'PostgreSQL', 27017: 'MongoDB'}

for sg in data['SecurityGroups']:
    sg_id = sg['GroupId']
    sg_name = sg['GroupName']

    for rule in sg['IpPermissions']:
        proto = rule.get('IpProtocol', '-1')
        from_port = rule.get('FromPort', 0)
        to_port = rule.get('ToPort', 65535)

        open_to_all = any(
            r.get('CidrIp') in ['0.0.0.0/0'] or r.get('CidrIpv6') in ['::/0']
            for r in rule.get('IpRanges', []) + rule.get('Ipv6Ranges', [])
        )

        if not open_to_all:
            continue

        # All traffic open
        if proto == '-1':
            print(f'CRITICAL: {sg_id} ({sg_name}) - ALL traffic open to 0.0.0.0/0')
            issues += 1

        # Sensitive port open
        elif isinstance(from_port, int):
            for port, service in SENSITIVE_PORTS.items():
                if from_port <= port <= to_port:
                    severity = 'CRITICAL' if service in ['SSH', 'RDP'] else 'WARNING'
                    print(f'{severity}: {sg_id} ({sg_name}) - {service} port {port} open to 0.0.0.0/0')
                    issues += 1

        # Wide port range open
        elif isinstance(from_port, int) and (to_port - from_port) > 100:
            print(f'WARNING: {sg_id} ({sg_name}) - Wide port range {from_port}-{to_port} open to 0.0.0.0/0')
            issues += 1

print(f'')
print(f'Total issues found: {issues}')
"

echo ""
echo "--- Checking for unused security groups ---"

# Get all SG IDs
ALL_SGS=$(echo "$SG_DATA" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for sg in data['SecurityGroups']:
    if sg['GroupName'] != 'default':
        print(sg['GroupId'], sg['GroupName'])
")

# Get attached SG IDs
ATTACHED=$(aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].SecurityGroups[*].GroupId' \
  --output text --region $REGION 2>/dev/null)

ATTACHED+=" "$(aws rds describe-db-instances \
  --query 'DBInstances[*].VpcSecurityGroups[*].VpcSecurityGroupId' \
  --output text --region $REGION 2>/dev/null)

echo "$ALL_SGS" | while read SG_ID SG_NAME; do
  if ! echo "$ATTACHED" | grep -q "$SG_ID"; then
    echo "UNUSED: $SG_ID ($SG_NAME) - not attached to any resource"
  fi
done

echo ""
echo "========================================"
echo "Audit complete"
echo "========================================"
