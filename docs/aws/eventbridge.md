# EventBridge - Event Automation

### What is EventBridge?
EventBridge is a serverless event bus that connects AWS services, SaaS apps, and custom applications using events.

### Architecture
Event Sources → EventBridge Bus → Rules → Targets
↓               ↓              ↓        ↓
AWS Services   Default Bus    Pattern   SNS/Lambda
Custom Apps    Custom Bus    Schedule   SQS/Step Functions
SaaS Apps

### Event Buses Created

1. **default** - Built-in AWS event bus (CloudWatch, EC2, etc.)
2. **myapp-event-bus** - Custom bus for application events

### Rules Created

#### Scheduled Rules (rate/cron)
| Rule | Schedule | Purpose |
|------|----------|---------|
| app-health-check | rate(5 minutes) | Regular health checks |
| metric-collection | rate(1 minute) | Metric collection trigger |
| daily-cleanup | cron(0 0 * * ? *) | Midnight cleanup |
| weekly-report | cron(0 9 ? * MON *) | Weekly report generation |

#### Pattern-Based Rules
| Rule | Source | Detail Type | Action |
|------|--------|-------------|--------|
| alarm-state-change | aws.cloudwatch | CloudWatch Alarm State Change | Critical SNS alert |
| ec2-state-change | aws.ec2 | EC2 Instance State-change | Warning SNS alert |
| app-error-event | myapp.backend | ApplicationError (CRITICAL/HIGH) | Critical SNS alert |
| deployment-event | myapp.cicd | DeploymentCompleted/Failed | Warning SNS alert |

### Event Pattern Examples

**CloudWatch Alarm ALARM state:**
```json
{
  "source": ["aws.cloudwatch"],
  "detail-type": ["CloudWatch Alarm State Change"],
  "detail": {
    "state": { "value": ["ALARM"] }
  }
}
```

**Custom application error:**
```json
{
  "source": ["myapp.backend"],
  "detail-type": ["ApplicationError"],
  "detail": {
    "severity": ["CRITICAL", "HIGH"]
  }
}
```

### Input Transformers

Transform event data before sending to target:
```hcl
input_transformer {
  input_paths = {
    alarm_name = "$.detail.alarmName"
    state      = "$.detail.state.value"
  }
  input_template = "\"ALARM: <alarm_name> is <state>\""
}
```

### Publishing Custom Events
```bash
# CLI
aws events put-events \
  --entries '[{
    "Source": "myapp.backend",
    "DetailType": "ApplicationError",
    "Detail": "{\"severity\": \"CRITICAL\"}",
    "EventBusName": "myapp-event-bus"
  }]'
```
```python
# Python
events_client.put_events(
    Entries=[{
        'Source': 'myapp.backend',
        'DetailType': 'ApplicationError',
        'Detail': json.dumps({'severity': 'CRITICAL'}),
        'EventBusName': 'myapp-event-bus'
    }]
)
```

### Testing Commands
```bash
# List event buses
aws --endpoint-url=http://localhost:4566 events list-event-buses

# List rules
aws --endpoint-url=http://localhost:4566 events list-rules

# List targets
aws --endpoint-url=http://localhost:4566 events list-targets-by-rule \
  --rule alarm-state-change

# Test a rule's pattern
aws --endpoint-url=http://localhost:4566 events test-event-pattern \
  --event-pattern '{"source":["myapp.backend"]}' \
  --event '{"source":"myapp.backend","detail-type":"ApplicationError"}'
```

### Best Practices

1. **Use custom event buses** for different applications/teams
2. **Use specific event patterns** to avoid unnecessary triggers
3. **Transform inputs** to send meaningful messages to targets
4. **Tag all rules** for cost allocation and management
5. **Enable/disable rules** instead of deleting for easy toggling
6. **Use DLQ (Dead Letter Queue)** for failed event handling
7. **Archive events** for replay and debugging

### EventBridge vs CloudWatch Events
EventBridge is the evolution of CloudWatch Events with:
- Custom event buses support
- SaaS partner integrations
- Schema registry
- Event replay capability


