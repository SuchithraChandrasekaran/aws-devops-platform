# Week 4 Architecture - Security Infrastructure

## Overview
Complete security architecture with IAM, encryption, network security, compliance monitoring, and automated response.

## Architecture Diagram 
## Security Controls by Layer

### Layer 1: IAM
- Application service role
- Worker service role
- Monitoring service role
- Admin role with conditions
- 6 least-privilege policies

### Layer 2: Encryption
- KMS key for secrets
- Secrets Manager (4 secrets)
- SSM Parameter Store (5 parameters)
- S3 bucket encryption
- TLS in transit

### Layer 3: Network
- VPC (10.0.0.0/16)
- 4 subnets (2 public, 2 private)
- 4 security groups
- 2 network ACLs
- VPC Flow Logs

### Layer 4: Monitoring
- CloudWatch Logs (3 groups)
- CloudWatch Alarms (10+)
- AWS Config (5 rules)
- VPC Flow Logs
- SNS notifications

### Layer 5: Response
- Security group remediation
- IAM policy remediation
- S3 bucket remediation
- EventBridge automation
- SNS alerts

### Layer 6: DevSecOps
- Secret detection
- Dependency scanning
- Container scanning
- SAST (Bandit)
- Infrastructure scanning
