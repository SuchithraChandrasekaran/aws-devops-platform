# IAM Security - Least Privilege Implementation

### Principle of Least Privilege
Grant only the permissions required to perform a specific task - nothing more.

### IAM Components Created

#### Policies (6)
1. **cloudwatch-logs-write** - Write to CloudWatch Logs
2. **cloudwatch-metrics-write** - Publish CloudWatch metrics
3. **sns-publish** - Publish to SNS topics
4. **eventbridge-put-events** - Publish EventBridge events
5. **s3-read-only** - Read from S3 buckets
6. **s3-write** - Write to S3 buckets

#### Roles (4)
1. **application-service-role** - For application EC2 instances
2. **worker-service-role** - For background worker instances
3. **monitoring-service-role** - For EventBridge monitoring
4. **admin-role** - Limited admin access with conditions

### Policy Design Patterns

#### Resource Scoping
```json
{
  "Resource": [
    "arn:aws:s3:::myapp-*",
    "arn:aws:s3:::myapp-*/*"
  ]
}
```
Limits access to only resources matching the pattern.

#### Action Scoping
```json
{
  "Action": [
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents"
  ]
}
```
Only specific actions, not `logs:*`.

#### Condition Keys
```json
{
  "Condition": {
    "StringEquals": {
      "cloudwatch:namespace": ["MyApp/Metrics"]
    }
  }
}
```
Further restricts when policy applies.

### Role Assume Policies

#### EC2 Service Role
```json
{
  "Principal": {
    "Service": "ec2.amazonaws.com"
  }
}
```

#### EventBridge Service Role
```json
{
  "Principal": {
    "Service": "events.amazonaws.com"
  }
}
```

#### Cross-Account with External ID
```json
{
  "Principal": {
    "AWS": "arn:aws:iam::000000000000:root"
  },
  "Condition": {
    "StringEquals": {
      "sts:ExternalId": "admin-access-dev"
    }
  }
}
```

### Permission Boundaries

Not implemented in Day 22 but important concept:
- Maximum permissions a role can have
- Useful for delegated administration
- Prevents privilege escalation

### Best Practices Applied

1. **Separate policies by function** - Logs, metrics, SNS, etc.
2. **Use resource ARN patterns** - `myapp-*` instead of `*`
3. **Avoid wildcards in actions** - Specify exact actions needed
4. **Add conditions when possible** - Namespace, tags, etc.
5. **Different roles for different services** - App, worker, monitoring
6. **Explicit deny for dangerous actions** - Prevent accidental deletion

### IAM Policy Evaluation Logic

- 1.Deny by default
- 2.Evaluate all applicable policies
- 3.Explicit Deny > Explicit Allow
- 4.If any policy denies, request is denied
- 5.If no policy allows, request is denied

