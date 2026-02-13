# CloudWatch Custom Metrics

## Day 15 Learning

### PutMetricData API
The PutMetricData API publishes metric data points to Amazon CloudWatch.

**Key Parameters:**
- `Namespace`: Custom namespace (e.g., MyApp/Performance)
- `MetricData`: Array of metric data
  - `MetricName`: Name of the metric
  - `Value`: The value for the metric
  - `Unit`: Count, Milliseconds, Bytes, etc.
  - `Timestamp`: Time of the metric (UTC)
  - `Dimensions`: Name-value pairs for filtering

**Example:**
```python
cloudwatch.put_metric_data(
    Namespace='MyApp/Performance',
    MetricData=[{
        'MetricName': 'RequestCount',
        'Value': 1.0,
        'Unit': 'Count',
        'Timestamp': datetime.utcnow(),
        'Dimensions': [
            {'Name': 'Environment', 'Value': 'dev'}
        ]
    }]
)
```

### Metrics Created
- **RequestCount**: Total number of requests (Count)
- **ResponseTime**: API response time (Milliseconds)
- **ErrorCount**: Number of errors (Count)

### Dimensions Used
- Environment: dev
- Service: api

### Dashboard
Created dashboard: `myapp-metrics-dashboard`
Visualizes all three metrics over time.

## Testing
Verified metrics flowing to CloudWatch:
1. Published metrics via PutMetricData API
2. Listed metrics via AWS CLI
3. Retrieved metric statistics
4. Instrumented Flask application
