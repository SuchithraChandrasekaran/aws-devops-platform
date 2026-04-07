# Days 15 to 18 Command Recall

## Day 16 - Implement centralized logging, configure log groups and streams

```bash
# Create log group
aws --endpoint-url=http://localhost:4566 logs create-log-group \
  --log-group-name "/myapp/dev"

# Create log stream
aws --endpoint-url=http://localhost:4566 logs create-log-stream \
  --log-group-name "/myapp/dev" \
  --log-stream-name "app-instance-1"

# Put log events
aws --endpoint-url=http://localhost:4566 logs put-log-events \
  --log-group-name "/myapp/dev" \
  --log-stream-name "app-instance-1" \
  --log-events timestamp=$(date +%s000),message="App started"

# Get log events
aws --endpoint-url=http://localhost:4566 logs get-log-events \
  --log-group-name "/myapp/dev" \
  --log-stream-name "app-instance-1"

# Set log retention policy (7 days)
aws --endpoint-url=http://localhost:4566 logs put-retention-policy \
  --log-group-name "/myapp/dev" \
  --retention-in-days 7

# Create metric filter (count errors)
aws --endpoint-url=http://localhost:4566 logs put-metric-filter \
  --log-group-name "/myapp/dev" \
  --filter-name "ErrorCount" \
  --filter-pattern "ERROR" \
  --metric-transformations \
    metricName=ErrorCount,metricNamespace=MyApp,metricValue=1
```

```javascript
// Send logs from Node.js app
const { CloudWatchLogsClient, PutLogEventsCommand } = require("@aws-sdk/client-cloudwatch-logs");

const client = new CloudWatchLogsClient({
  region: "us-east-1",
  endpoint: "http://localhost:4566",
  credentials: { accessKeyId: "test", secretAccessKey: "test" }
});

async function log(message) {
  await client.send(new PutLogEventsCommand({
    logGroupName: "/myapp/dev",
    logStreamName: "app-instance-1",
    logEvents: [{ timestamp: Date.now(), message }]
  }));
}

log("ERROR: something went wrong");
```

---

## Day 17 - Create 10+ CloudWatch alarms (CPU, memory, errors, latency) → SNS

```bash
# Create SNS topic for alarm notifications
aws --endpoint-url=http://localhost:4566 sns create-topic --name my-alerts
# Note the TopicArn from output

# Subscribe email to topic
aws --endpoint-url=http://localhost:4566 sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:000000000000:my-alerts \
  --protocol email \
  --notification-endpoint you@example.com

# Alarm 1: High CPU
aws --endpoint-url=http://localhost:4566 cloudwatch put-metric-alarm \
  --alarm-name "HighCPU" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:us-east-1:000000000000:my-alerts

# Alarm 2: High memory
aws --endpoint-url=http://localhost:4566 cloudwatch put-metric-alarm \
  --alarm-name "HighMemory" \
  --metric-name MemoryUtilization \
  --namespace MyApp \
  --statistic Average \
  --period 300 \
  --threshold 85 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:us-east-1:000000000000:my-alerts

# Alarm 3: Error rate
aws --endpoint-url=http://localhost:4566 cloudwatch put-metric-alarm \
  --alarm-name "HighErrorRate" \
  --metric-name ErrorCount \
  --namespace MyApp \
  --statistic Sum \
  --period 60 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:us-east-1:000000000000:my-alerts

# Alarm 4: High latency
aws --endpoint-url=http://localhost:4566 cloudwatch put-metric-alarm \
  --alarm-name "HighLatency" \
  --metric-name Latency \
  --namespace MyApp \
  --statistic Average \
  --period 60 \
  --threshold 1000 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:us-east-1:000000000000:my-alerts

# List all alarms
aws --endpoint-url=http://localhost:4566 cloudwatch describe-alarms

# Manually trigger alarm state for testing
aws --endpoint-url=http://localhost:4566 cloudwatch set-alarm-state \
  --alarm-name "HighCPU" \
  --state-value ALARM \
  --state-reason "Testing"
```

---

## Day 18 - Build comprehensive CloudWatch dashboard with 15+ widgets

```bash
# Create dashboard with widgets (metrics, alarms, logs)
aws --endpoint-url=http://localhost:4566 cloudwatch put-dashboard \
  --dashboard-name "MyAppDashboard" \
  --dashboard-body '{
    "widgets": [
      {
        "type": "metric",
        "x": 0, "y": 0, "width": 12, "height": 6,
        "properties": {
          "title": "CPU Utilization",
          "metrics": [["AWS/EC2", "CPUUtilization"]],
          "period": 300,
          "stat": "Average",
          "view": "timeSeries"
        }
      },
      {
        "type": "metric",
        "x": 12, "y": 0, "width": 12, "height": 6,
        "properties": {
          "title": "Error Count",
          "metrics": [["MyApp", "ErrorCount"]],
          "period": 60,
          "stat": "Sum",
          "view": "timeSeries"
        }
      },
      {
        "type": "alarm",
        "x": 0, "y": 6, "width": 6, "height": 3,
        "properties": {
          "title": "Alarm Status",
          "alarms": [
            "arn:aws:cloudwatch:us-east-1:000000000000:alarm:HighCPU",
            "arn:aws:cloudwatch:us-east-1:000000000000:alarm:HighMemory",
            "arn:aws:cloudwatch:us-east-1:000000000000:alarm:HighErrorRate",
            "arn:aws:cloudwatch:us-east-1:000000000000:alarm:HighLatency"
          ]
        }
      },
      {
        "type": "log",
        "x": 6, "y": 6, "width": 18, "height": 6,
        "properties": {
          "title": "App Logs",
          "query": "SOURCE \"/myapp/dev\" | fields @timestamp, @message | sort @timestamp desc | limit 50",
          "view": "table"
        }
      }
    ]
  }'

# List dashboards
aws --endpoint-url=http://localhost:4566 cloudwatch list-dashboards

# Get dashboard
aws --endpoint-url=http://localhost:4566 cloudwatch get-dashboard \
  --dashboard-name "MyAppDashboard"

# Delete dashboard
aws --endpoint-url=http://localhost:4566 cloudwatch delete-dashboards \
  --dashboard-names "MyAppDashboard"
```

---
