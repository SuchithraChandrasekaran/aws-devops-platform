# Days 47 to 50 Command Recall

---

## Day 47 - CloudWatch Dashboard Enhancement

```bash
# Update existing dashboard with more widgets
aws cloudwatch put-dashboard \
  --dashboard-name "MyAppDashboard" \
  --dashboard-body '{
    "widgets": [
      {
        "type": "metric",
        "x": 0, "y": 0, "width": 8, "height": 6,
        "properties": {
          "title": "EC2 CPU Utilization",
          "metrics": [["AWS/EC2", "CPUUtilization", "InstanceId", "<instance-id>"]],
          "period": 300, "stat": "Average", "view": "timeSeries"
        }
      },
      {
        "type": "metric",
        "x": 8, "y": 0, "width": 8, "height": 6,
        "properties": {
          "title": "App Request Count",
          "metrics": [["MyApp", "RequestCount", "Environment", "prod"]],
          "period": 60, "stat": "Sum", "view": "timeSeries"
        }
      },
      {
        "type": "metric",
        "x": 16, "y": 0, "width": 8, "height": 6,
        "properties": {
          "title": "App Response Time (ms)",
          "metrics": [["MyApp", "ResponseTimeMs", "Environment", "prod"]],
          "period": 60, "stat": "Average", "view": "timeSeries"
        }
      },
      {
        "type": "metric",
        "x": 0, "y": 6, "width": 8, "height": 6,
        "properties": {
          "title": "Error Count",
          "metrics": [["MyApp", "ErrorCount", "Environment", "prod"]],
          "period": 60, "stat": "Sum", "view": "timeSeries"
        }
      },
      {
        "type": "metric",
        "x": 8, "y": 6, "width": 8, "height": 6,
        "properties": {
          "title": "RDS CPU",
          "metrics": [["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "myapp-db"]],
          "period": 300, "stat": "Average", "view": "timeSeries"
        }
      },
      {
        "type": "metric",
        "x": 16, "y": 6, "width": 8, "height": 6,
        "properties": {
          "title": "RDS Free Storage",
          "metrics": [["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "myapp-db"]],
          "period": 300, "stat": "Average", "view": "timeSeries"
        }
      },
      {
        "type": "alarm",
        "x": 0, "y": 12, "width": 24, "height": 3,
        "properties": {
          "title": "All Alarms",
          "alarms": [
            "arn:aws:cloudwatch:us-east-1:<account-id>:alarm:EC2-HighCPU",
            "arn:aws:cloudwatch:us-east-1:<account-id>:alarm:RDS-HighCPU",
            "arn:aws:cloudwatch:us-east-1:<account-id>:alarm:App-HighErrors",
            "arn:aws:cloudwatch:us-east-1:<account-id>:alarm:App-SlowResponse"
          ]
        }
      },
      {
        "type": "log",
        "x": 0, "y": 15, "width": 24, "height": 6,
        "properties": {
          "title": "Recent App Logs",
          "query": "SOURCE \"/myapp/prod\" | fields @timestamp, @message | sort @timestamp desc | limit 50",
          "view": "table"
        }
      }
    ]
  }'

# List dashboards
aws cloudwatch list-dashboards

# Get dashboard JSON
aws cloudwatch get-dashboard --dashboard-name "MyAppDashboard"
```

---

## Day 48 - EventBridge Automation Rules

```bash
# Rule 1: Auto-stop EC2 at night (9pm daily)
aws events put-rule \
  --name "NightlyStopEC2" \
  --schedule-expression "cron(0 21 * * ? *)" \
  --state ENABLED

aws events put-targets \
  --rule "NightlyStopEC2" \
  --targets Id=1,Arn=arn:aws:lambda:us-east-1:<account-id>:function:auto-stop-resources

# Rule 2: Auto-start EC2 in morning (8am daily)
aws events put-rule \
  --name "MorningStartEC2" \
  --schedule-expression "cron(0 8 * * ? *)" \
  --state ENABLED

aws events put-targets \
  --rule "MorningStartEC2" \
  --targets Id=1,Arn=arn:aws:lambda:us-east-1:<account-id>:function:auto-stop-resources

# Rule 3: Trigger health check every 5 minutes
aws events put-rule \
  --name "HealthCheckSchedule" \
  --schedule-expression "rate(5 minutes)" \
  --state ENABLED

aws events put-targets \
  --rule "HealthCheckSchedule" \
  --targets Id=1,Arn=arn:aws:lambda:us-east-1:<account-id>:function:health-check

# Rule 4: React to EC2 state change (auto-tag on launch)
aws events put-rule \
  --name "EC2StateChange" \
  --event-pattern '{
    "source": ["aws.ec2"],
    "detail-type": ["EC2 Instance State-change Notification"],
    "detail": { "state": ["running"] }
  }' \
  --state ENABLED

aws events put-targets \
  --rule "EC2StateChange" \
  --targets Id=1,Arn=arn:aws:lambda:us-east-1:<account-id>:function:auto-tag

# Rule 5: React to RDS event (notify on failover)
aws events put-rule \
  --name "RDSFailover" \
  --event-pattern '{
    "source": ["aws.rds"],
    "detail-type": ["RDS DB Instance Event"],
    "detail": { "EventID": ["RDS-EVENT-0049"] }
  }' \
  --state ENABLED

aws events put-targets \
  --rule "RDSFailover" \
  --targets Id=1,Arn=arn:aws:sns:us-east-1:<account-id>:my-alerts

# List all rules
aws events list-rules

# Disable a rule temporarily
aws events disable-rule --name "NightlyStopEC2"

# Enable again
aws events enable-rule --name "NightlyStopEC2"
```

---

## Day 49 - Lambda Auto-remediation on Real AWS

```bash
# Update Lambda with real AWS endpoints (remove LocalStack overrides)
zip remediate.zip lambda/remediate.js

aws lambda update-function-code \
  --function-name security-remediator \
  --zip-file fileb://remediate.zip

# Update environment variables
aws lambda update-function-configuration \
  --function-name security-remediator \
  --environment Variables='{
    "SNS_TOPIC_ARN": "arn:aws:sns:us-east-1:<account-id>:my-alerts",
    "ENVIRONMENT": "prod"
  }'

# Grant EventBridge permission to invoke Lambda
aws lambda add-permission \
  --function-name security-remediator \
  --statement-id "EventBridgeInvoke" \
  --action lambda:InvokeFunction \
  --principal events.amazonaws.com \
  --source-arn arn:aws:events:us-east-1:<account-id>:rule/SecurityRemediation

# Test Lambda invocation
aws lambda invoke \
  --function-name security-remediator \
  --payload '{"detail": {"type": "UnauthorizedAccess:EC2/SSHBruteForce", "resource": {"instanceDetails": {"instanceId": "<instance-id>"}}}}' \
  response.json

cat response.json

# Check Lambda logs in CloudWatch
aws logs tail /aws/lambda/security-remediator --follow

# Check Lambda metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=security-remediator \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 --statistics Sum

# Check errors
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Errors \
  --dimensions Name=FunctionName,Value=security-remediator \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 --statistics Sum
```

---

## Day 50 - SNS Alerting to Email/SMS

```bash
# Create SNS topic
aws sns create-topic --name myapp-alerts

# Subscribe email
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:<account-id>:myapp-alerts \
  --protocol email \
  --notification-endpoint you@example.com

# Subscribe SMS (phone number)
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:<account-id>:myapp-alerts \
  --protocol sms \
  --notification-endpoint +1234567890

# List subscriptions
aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:us-east-1:<account-id>:myapp-alerts

# Publish a test alert
aws sns publish \
  --topic-arn arn:aws:sns:us-east-1:<account-id>:myapp-alerts \
  --subject "Test Alert from MyApp" \
  --message "This is a test alert. All systems operational."

# Publish structured alert (JSON)
aws sns publish \
  --topic-arn arn:aws:sns:us-east-1:<account-id>:myapp-alerts \
  --message-structure json \
  --message '{
    "default": "App alert triggered",
    "email": "ALERT: High error rate detected on prod. ErrorCount exceeded threshold of 10.",
    "sms": "MyApp ALERT: High errors on prod!"
  }'

# Wire CloudWatch alarm to SNS (update existing alarm)
aws cloudwatch put-metric-alarm \
  --alarm-name "App-HighErrors" \
  --namespace MyApp \
  --metric-name ErrorCount \
  --statistic Sum --period 60 --threshold 10 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:us-east-1:<account-id>:myapp-alerts \
  --ok-actions arn:aws:sns:us-east-1:<account-id>:myapp-alerts \
  --insufficient-data-actions arn:aws:sns:us-east-1:<account-id>:myapp-alerts

# Set SMS spending limit (avoid surprise charges)
aws sns set-sms-attributes \
  --attributes MonthlySpendLimit=1

# Check SNS delivery status
aws sns get-topic-attributes \
  --topic-arn arn:aws:sns:us-east-1:<account-id>:myapp-alerts
```

---
