# Security Auto-Remediation

### Lambda Functions Created

**1. Security Group Remediation (sg_remediation.py)**
- Removes 0.0.0.0/0 access on SSH (22) and RDP (3389)
- Isolates compromised instances
- Creates isolation security groups

**2. IAM Policy Remediation (iam_remediation.py)**
- Detaches overly permissive policies
- Removes dangerous inline policies
- Checks for wildcard permissions

**3. S3 Bucket Remediation (s3_remediation.py)**
- Enables bucket encryption
- Blocks public access
- Enables versioning
- Enables access logging

### Trigger Mechanism

EventBridge rule captures findings from:
- GuardDuty
- Security Hub

Event pattern matches security findings and triggers appropriate Lambda.

### Remediation Actions

**Security Group Issues:**
- Remove public SSH/RDP access
- Isolate compromised instances
- Apply restrictive security groups

**IAM Issues:**
- Detach admin policies
- Remove wildcard permissions
- Delete dangerous inline policies

**S3 Issues:**
- Enable encryption (AES256)
- Block all public access
- Enable versioning
- Configure logging

### Best Practices

1. Test in non-production first
2. Send notifications before remediation
3. Log all remediation actions
4. Maintain rollback procedures
5. Review remediated resources
6. Update security policies
7. Monitor for false positives
