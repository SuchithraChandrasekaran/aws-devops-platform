# AWS Config - Compliance Monitoring

## Day 25 Learning

### AWS Config Components

**Configuration Recorder:**
- Records resource configurations
- Captures configuration changes
- Tracks resource relationships

**Delivery Channel:**
- Delivers configuration snapshots to S3
- Sends configuration history
- Enables compliance reporting

**Config Rules:**
- Evaluate resource compliance
- Managed rules (AWS provided)
- Custom rules (Lambda based)

### Config Rules Created

#### Managed Rules (5)

1. **s3-bucket-server-side-encryption-enabled**
   - Checks S3 bucket encryption
   - No parameters required
   - Owner: AWS

2. **cloudtrail-enabled**
   - Checks if CloudTrail is enabled
   - No parameters required
   - Owner: AWS

3. **approved-amis-by-id**
   - Checks EC2 instances use approved AMIs
   - Parameters: AMI IDs list
   - Owner: AWS

4. **iam-password-policy**
   - Checks IAM password policy requirements
   - Parameters: Length, complexity, age
   - Owner: AWS

5. **rds-storage-encrypted**
   - Checks RDS encryption at rest
   - No parameters required
   - Owner: AWS

#### Custom Rules (1)

6. **required-tags-check**
   - Checks if resources have required tags
   - Tags: Environment, Owner, Project
   - Owner: CUSTOM_LAMBDA
   - Lambda function evaluates compliance

### Compliance States

- **COMPLIANT**: Resource meets requirements
- **NON_COMPLIANT**: Resource violates rule
- **INSUFFICIENT_DATA**: Not enough data to evaluate
- **NOT_APPLICABLE**: Rule doesn't apply to resource

### Config Rule Evaluation

**Trigger Types:**
- Configuration changes
- Periodic evaluation
- On-demand evaluation

**Evaluation Process:**
1. Resource configuration change detected
2. Config rule triggered
3. Rule evaluates configuration
4. Compliance status recorded
5. Notification sent if non-compliant

### Custom Rule Lambda Function
```python
def lambda_handler(event, context):
    # Parse configuration item
    config_item = event['configurationItem']
    
    # Check compliance
    if meets_requirements(config_item):
        compliance = 'COMPLIANT'
    else:
        compliance = 'NON_COMPLIANT'
    
    # Put evaluation
    config.put_evaluations(
        Evaluations=[{
            'ComplianceType': compliance,
            'ComplianceResourceId': resource_id,
            'OrderingTimestamp': timestamp
        }],
        ResultToken=event['resultToken']
    )
```

### Config vs CloudTrail vs CloudWatch

| Service | Purpose | Focus |
|---------|---------|-------|
| Config | Compliance | Resource configuration state |
| CloudTrail | Audit | API activity logging |
| CloudWatch | Monitoring | Metrics and logs |

### Remediation Actions

**Automated Remediation:**
- Trigger SSM Automation documents
- Fix non-compliant resources automatically
- Requires remediation action configuration

**Manual Remediation:**
- Review non-compliant resources
- Apply fixes manually
- Document remediation steps

### Testing Commands
```bash
# List config rules
aws configservice describe-config-rules

# Get compliance status
aws configservice describe-compliance-by-config-rule

# Get rule details
aws configservice describe-config-rules --config-rule-names <rule-name>

# Start rule evaluation
aws configservice start-config-rules-evaluation --config-rule-names <rule-name>

# Get compliance details by resource
aws configservice describe-compliance-by-resource --resource-type AWS::EC2::Instance
```

### Best Practices

1. Start with AWS managed rules
2. Create custom rules for specific requirements
3. Set up automated remediation where possible
4. Regular compliance reporting
5. Integrate with SNS for notifications
6. Use conformance packs for bundled rules
7. Tag all resources for better tracking
8. Review non-compliant resources regularly

### Cost Considerations

**Config Pricing:**
- Configuration item recorded: $0.003 per item
- Config rule evaluation: $0.001 per evaluation
- Conformance pack evaluation: $0.0012 per evaluation

**Cost Optimization:**
- Monitor only required resource types
- Use periodic evaluation instead of continuous
- Aggregate multi-account data
- Set appropriate retention policies

### Next Steps

- Implement automated remediation
- Create conformance packs
- Multi-account aggregation
- Integration with Security Hub
- Custom compliance dashboards
