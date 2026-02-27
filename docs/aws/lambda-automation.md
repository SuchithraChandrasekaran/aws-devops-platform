# Lambda Automation Functions

### Functions Deployed

**1. Auto-Stop Resources**
- Purpose: Cost optimization
- Schedule: Daily at 6 PM
- Actions: Stops EC2 and RDS with AutoStop tag

**2. Auto-Tag**
- Purpose: Governance and compliance
- Trigger: Resource creation events
- Actions: Adds standard tags automatically

**3. Backup Verify**
- Purpose: Data protection
- Schedule: Daily at 9 AM
- Actions: Verifies backups are current

**4. Security Remediation**
- Purpose: Security automation
- Trigger: Security findings
- Actions: Fixes security misconfigurations

**5. Health Check**
- Purpose: Monitoring
- Schedule: Every 5 minutes
- Actions: Checks infrastructure health

### Lambda Best Practices

1. Least privilege IAM roles
2. Environment variables for configuration
3. Proper error handling
4. Logging for debugging
5. Timeout configuration
6. Idempotent operations

### Cost Optimization

**Lambda Pricing:**
- Free tier: 1M requests/month
- Free tier: 400,000 GB-seconds/month
- After: $0.20 per 1M requests
