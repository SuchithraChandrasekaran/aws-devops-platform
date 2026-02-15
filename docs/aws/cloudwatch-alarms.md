# CloudWatch Alarms & SNS


### Alarm Components
- **Metric**: What to monitor (CPU, memory, errors, etc.)
- **Threshold**: Trigger value that causes alarm
- **Evaluation Periods**: How many periods to check before alarming
- **Statistic**: How to aggregate data (Average, Sum, Maximum, etc.)
- **Actions**: What to do when triggered (SNS notification)

### Alarms Created (10+)

#### Critical Alarms (sent to critical-alerts topic)
1. **high-cpu-utilization**: >80% CPU for 2 periods (10 min)
2. **high-memory-utilization**: >85% memory for 2 periods (10 min)
3. **high-error-count**: >10 errors per 5 min period
4. **high-disk-usage**: >90% disk for 1 period (5 min)
5. **high-db-connections**: >80 connections for 2 periods (10 min)
6. **high-queue-depth**: >100 messages for 1 period (5 min)

#### Warning Alarms (sent to warning-alerts topic)
7. **high-api-latency**: >1000ms average for 2 periods (10 min)
8. **high-network-throughput**: >1MB/s for 2 periods (10 min)
9. **low-request-count**: <10 requests per 5 min for 2 periods
10. **low-cache-hit-rate**: <70% cache hit rate for 2 periods (10 min)

### Composite Alarm

**system-unhealthy:**
- **Rule**: CPU OR Memory OR (Errors AND Latency)
- **Purpose**: Overall system health indicator
- **Action**: Critical alert to SNS
- **Logic**: Triggers if any single critical resource alarm fires, or if both errors and latency are high simultaneously

### Alarm States

1. **OK**: Metric is within acceptable threshold
2. **ALARM**: Metric has breached threshold for specified evaluation periods
3. **INSUFFICIENT_DATA**: Not enough data points to evaluate alarm

### SNS Topics

1. **critical-alerts**: High severity issues requiring immediate attention
2. **warning-alerts**: Medium severity issues for monitoring
3. **info-alerts**: Low severity notifications and informational messages

### Alarm Properties

**Comparison Operators:**
- GreaterThanThreshold
- LessThanThreshold
- GreaterThanOrEqualToThreshold
- LessThanOrEqualToThreshold

**Statistics:**
- Average: Mean value over period
- Sum: Total of all values
- Maximum: Highest value in period
- Minimum: Lowest value in period

**Period:**
- Minimum: 60 seconds
- Standard: 300 seconds (5 minutes)
- Data is evaluated over this time window

### Testing Commands

**List all alarms:**
```bash
aws --endpoint-url=http://localhost:4566 cloudwatch describe-alarms
```

**Check specific alarm:**
```bash
aws --endpoint-url=http://localhost:4566 cloudwatch describe-alarms \
  --alarm-names high-cpu-utilization
```

**View alarm history:**
```bash
aws --endpoint-url=http://localhost:4566 cloudwatch describe-alarm-history \
  --alarm-name high-cpu-utilization
```

**Send test metric data:**
```bash
aws --endpoint-url=http://localhost:4566 cloudwatch put-metric-data \
  --namespace MyApp/Metrics \
  --metric-name CPUUtilization \
  --value 90 \
  --unit Percent
```

### Best Practices

1. **Use appropriate thresholds**: Based on baseline metrics and SLAs
2. **Set evaluation periods**: Avoid false alarms from temporary spikes
3. **Group related alarms**: Use composite alarms for complex conditions
4. **Test regularly**: Verify alarms trigger correctly
5. **Document alarm responses**: What to do when each alarm fires
6. **Use SNS topics by severity**: Route to appropriate teams
7. **Monitor alarm states**: Track INSUFFICIENT_DATA states

### Architecture
Metrics → CloudWatch Alarms → SNS Topics → Email/SMS/Lambda
↓
Composite Alarms → SNS Topics
