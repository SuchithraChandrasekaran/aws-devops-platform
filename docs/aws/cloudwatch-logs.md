# CloudWatch Logs

### Log Groups and Streams
- Log Group: Container for log streams (e.g., /aws/application/myapp)
- Log Stream: Sequence of log events from same source (e.g., app-stream)

### Log Groups Created
1. /aws/application/myapp - Application logs
2. /aws/api/myapp - API request logs
3. /aws/errors/myapp - Error logs (14 day retention)

### Metric Filters
Transform log data into CloudWatch metrics:

**Error Count Filter:**
- Pattern: [ERROR]
- Metric: ErrorCountFromLogs in MyApp/Logs namespace

**API Latency Filter:**
- Pattern: [time, request_id, latency]
- Metric: APIResponseTime in MyApp/Logs namespace

### PutLogEvents API
```python
logs_client.put_log_events(
    logGroupName='/aws/application/myapp',
    logStreamName='app-stream',
    logEvents=[{
        'timestamp': int(time.time() * 1000),
        'message': '[INFO] Application started'
    }]
)
```

### CloudWatch Logs Insights
Query language for analyzing logs:
```
fields @timestamp, @message
| filter @message like /ERROR/
| stats count() by bin(5m)
```

## Testing
- Centralized logger implemented
- Multiple log groups and streams configured
- Metric filters extracting metrics from logs
- Application instrumented with logging
