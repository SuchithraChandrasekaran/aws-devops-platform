# Security Baseline Checklist

## IAM Security
- [ ] No root account usage
- [ ] MFA enabled for all users
- [ ] Least privilege IAM policies
- [ ] No hardcoded credentials
- [ ] IAM password policy enforced
- [ ] Service roles use minimal permissions
- [ ] Access keys rotated regularly

## Network Security
- [ ] VPC with public/private subnets
- [ ] Security groups follow least privilege
- [ ] Network ACLs configured
- [ ] No unrestricted SSH (0.0.0.0/0:22)
- [ ] No unrestricted RDP (0.0.0.0/0:3389)
- [ ] VPC Flow Logs enabled
- [ ] Private subnets for databases

## Data Encryption
- [ ] S3 buckets encrypted at rest
- [ ] EBS volumes encrypted
- [ ] RDS encryption enabled
- [ ] Secrets in Secrets Manager/SSM
- [ ] TLS/SSL for data in transit
- [ ] KMS keys for sensitive data

## Monitoring and Logging
- [ ] CloudWatch Logs enabled
- [ ] CloudTrail enabled
- [ ] Config recording active
- [ ] VPC Flow Logs active
- [ ] Log retention configured
- [ ] Alerts for security events

## Compliance
- [ ] AWS Config rules active
- [ ] Security Hub enabled (production)
- [ ] GuardDuty enabled (production)
- [ ] Resource tagging enforced
- [ ] Backup policies configured
- [ ] Disaster recovery plan

## Application Security
- [ ] No secrets in code
- [ ] Dependencies scanned
- [ ] Container images scanned
- [ ] SAST in CI/CD pipeline
- [ ] Security headers configured
- [ ] Input validation

## Incident Response
- [ ] Auto-remediation lambdas deployed
- [ ] SNS notifications configured
- [ ] Incident response playbook
- [ ] Security contact documented
- [ ] Vulnerability response plan
