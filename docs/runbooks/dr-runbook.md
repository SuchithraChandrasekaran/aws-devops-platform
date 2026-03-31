# Disaster Recovery Runbook
Last updated: DAY_61_DATE
Owner: aws-devops-platform

---

## Severity Levels

| Level    | Definition                                  | Target Recovery Time |
|----------|---------------------------------------------|----------------------|
| P1       | Production down, users impacted             | < 1 hour             |
| P2       | Degraded performance, partial outage        | < 4 hours            |
| P3       | Non-critical component failure              | < 24 hours           |

---

## Scenario 1 — EC2 Instance Unresponsive or Terminated

**Symptoms:** SSH fails, health checks fail, instance shows terminated in console.

**Steps:**
1. Confirm the failure:
```bash
   aws ec2 describe-instances --instance-ids <INSTANCE_ID> \
     --query 'Reservations[0].Instances[0].State.Name' --output text
```
2. Find the latest DR AMI:
```bash
   aws ec2 describe-images --owners self \
     --filters "Name=tag:Purpose,Values=DR" \
     --query 'sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]' \
     --output table
```
3. Run the recovery script:
```bash
   ./scripts/dr/recover-ec2.sh <AMI_ID> <SUBNET_ID> <SG_ID> <KEY_NAME>
```
4. Verify application on new instance.
5. Update DNS / Elastic IP to point to new instance.

**RTO target:** 30 minutes
**Script:** `scripts/dr/recover-ec2.sh`

---

## Scenario 2 — Accidental S3 Object Deletion

**Symptoms:** Application returns 404, missing file errors in logs.

**Steps:**
1. Check if versioning is enabled:
```bash
   aws s3api get-bucket-versioning --bucket <BUCKET_NAME>
```
2. Run the recovery script:
```bash
   ./scripts/dr/recover-s3.sh <BUCKET_NAME> <OBJECT_KEY>
```
3. Verify object is accessible:
```bash
   aws s3 ls s3://<BUCKET_NAME>/<OBJECT_KEY>
```

**RTO target:** 5 minutes (if versioning was enabled)
**Script:** `scripts/dr/recover-s3.sh`
**Prevention:** Always enable S3 versioning on production buckets.

---

## Scenario 3 — RDS Database Failure

**Symptoms:** Application DB connection errors, RDS console shows failed status.

**Steps:**
1. Check RDS status:
```bash
   aws rds describe-db-instances \
     --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,LatestRestorableTime]' \
     --output table
```
2. Restore from latest automated backup:
```bash
   aws rds restore-db-instance-to-point-in-time \
     --source-db-instance-identifier <DB_ID> \
     --target-db-instance-identifier <DB_ID>-recovered \
     --restore-time <LATEST_RESTORABLE_TIME> \
     --region us-east-1
```
3. Update application DB connection string to point to recovered instance.
4. Verify connectivity:
```bash
   psql -h <NEW_ENDPOINT> -U <USER> -d <DB_NAME> -c "SELECT 1;"
```

**RTO target:** 45 minutes
**Prevention:** Keep BackupRetentionPeriod >= 7 days. STOP RDS when not using (free tier).

---

## Scenario 4 — Accidental Security Group / IAM Change Locks You Out

**Symptoms:** SSH blocked, AWS console access denied.

**Steps:**
1. Log in via AWS Console (if API access is blocked).
2. Go to EC2 → Security Groups → find your SG → add inbound SSH from your IP.
3. If IAM locked out, use root account to restore IAM user permissions.
4. Re-run audits after recovery:
```bash
   ./scripts/sg-audit.sh
   ./scripts/iam-audit.sh
```

**RTO target:** 15 minutes
**Prevention:** Never delete the last admin IAM user. Keep root MFA enabled.

---

## DR Script Index

| Script                         | Purpose                              |
|--------------------------------|--------------------------------------|
| `scripts/dr/recover-ec2.sh`    | Launch new EC2 from DR AMI           |
| `scripts/dr/recover-s3.sh`     | Restore deleted S3 objects           |
| `scripts/sg-audit.sh`          | Re-audit security groups post-DR     |
| `scripts/iam-audit.sh`         | Re-audit IAM roles post-DR           |

---

## Post-Recovery Checklist

- [ ] New resource is healthy and application responds
- [ ] DNS / Elastic IP updated to new resource
- [ ] Team notified of recovery and new endpoints
- [ ] Root cause identified and documented
- [ ] Preventive fix applied (e.g. enable MFA, enable versioning)
- [ ] DR scripts and runbook updated if gaps were found
- [ ] `git commit` the updated runbook with lessons learned

