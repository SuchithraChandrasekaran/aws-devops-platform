# CloudWatch Dashboards

## Day 18 Learning

### Dashboard Overview
Dashboards provide a customizable view of your metrics, alarms, and logs in a single place.

### Operations Dashboard Created

**Dashboard Name:** operations-dashboard  
**Total Widgets:** 16+  
**Layout:** Grid-based (24 columns wide)

### Widget Types

#### 1. Metric Widgets (Line Charts)
Display time-series data as line graphs:
- CPU Utilization
- Memory Utilization
- Disk Utilization
- Network Throughput
- Request Count
- Error Count
- API Response Time
- Database Connections
- Cache Hit Rate
- Queue Depth

#### 2. Number Widgets (Single Value)
Display current metric values:
- Current CPU %
- Current Memory %
- Total Errors (Last Hour)
- Total Requests (Last Hour)

#### 3. Alarm Widget
Shows status of multiple alarms:
- high-cpu-utilization
- high-memory-utilization
- high-error-count
- high-api-latency

#### 4. Log Insights Widget
Displays query results from CloudWatch Logs:
- Recent error messages from application logs

### Widget Properties

**Common Properties:**
- `type`: Widget type (metric, alarm, log)
- `x`, `y`: Position on grid
- `width`, `height`: Size in grid units
- `properties`: Widget-specific configuration

**Metric Widget Properties:**
- `metrics`: Array of metrics to display
- `period`: Data aggregation period (seconds)
- `stat`: Statistic (Average, Sum, Maximum, Minimum)
- `region`: AWS region
- `title`: Widget title
- `yAxis`: Y-axis configuration (min, max)
- `view`: Display mode (timeSeries, singleValue)

**Alarm Widget Properties:**
- `alarms`: Array of alarm ARNs to display

**Log Widget Properties:**
- `query`: CloudWatch Logs Insights query
- `region`: AWS region

### AWS CLI Commands

**List dashboards:**
```bash
aws cloudwatch list-dashboards
```

**Get dashboard:**
```bash
aws cloudwatch get-dashboard --dashboard-name operations-dashboard
```

**Put dashboard (create/update):**
```bash
aws cloudwatch put-dashboard \
  --dashboard-name my-dashboard \
  --dashboard-body file://dashboard.json
```

**Delete dashboard:**
```bash
aws cloudwatch delete-dashboards --dashboard-names operations-dashboard
```

### Dashboard JSON Structure
```json
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          ["Namespace", "MetricName", { "stat": "Average" }]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "Widget Title"
      }
    }
  ]
}
```

### Best Practices

1. **Organize logically**: Group related metrics together
2. **Use appropriate chart types**: Line charts for trends, numbers for current values
3. **Set meaningful titles**: Clear, descriptive widget names
4. **Configure Y-axis**: Set min/max for percentage metrics
5. **Use appropriate periods**: 300s (5min) for general monitoring
6. **Include alarms**: Show alarm status alongside metrics
7. **Add log queries**: Include error logs for troubleshooting
8. **Optimize layout**: Most important metrics at the top

### Metric Visualization Tips

**Line Charts:**
- Best for: Trends over time
- Use for: CPU, memory, latency, throughput

**Number Widgets:**
- Best for: Current state
- Use for: Latest value, totals

**Alarm Widgets:**
- Best for: Overall health
- Use for: Quick status check

**Log Widgets:**
- Best for: Troubleshooting
- Use for: Error investigation

### Testing Commands

**Send test metrics:**
```bash
aws cloudwatch put-metric-data \
  --namespace MyApp/Metrics \
  --metric-name CPUUtilization \
  --value 75 \
  --unit Percent
```

**Query dashboard:**
```bash
aws cloudwatch get-dashboard \
  --dashboard-name operations-dashboard \
  --query 'DashboardBody' | python -m json.tool
```
