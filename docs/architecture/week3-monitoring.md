## Components Built (Days 16-21)

### Day 16: CloudWatch Logs & Centralized Logging
- 3 log groups (application, API, errors)
- 3 log streams
- 2 metric filters (error count, API latency)
- Centralized logging script

### Day 17: CloudWatch Alarms & SNS
- 10 metric alarms
- 1 composite alarm
- 3 SNS topics (critical, warning, info)
- Email subscriptions
- Alarm testing scripts

### Day 18: CloudWatch Dashboards
- Operations dashboard with 16+ widgets
- Metric line charts (10)
- Number widgets (4)
- Alarm status widget (1)
- Log insights widget (1)

### Day 19: Prometheus & Grafana
- Prometheus metrics collection
- Grafana visualization
- Node Exporter (system metrics)
- Custom App Exporter (business metrics)
- 4 Docker containers

### Day 20: EventBridge Event Automation
- Custom event bus
- 4 scheduled rules (rate/cron)
- 4 pattern rules (event-driven)
- 8 SNS targets with transformers

### Day 21: Integration & Testing
- Comprehensive integration tests
- End-to-end workflow validation
- Architecture documentation

## Metrics Collected

### System Metrics
- CPU Utilization
- Memory Utilization
- Disk Utilization
- Network Throughput

### Application Metrics
- Request Count
- Error Count
- API Response Time
- Active Connections
- Queue Depth
- Cache Hit Rate
- Database Connections

## Alerting Strategy

### Critical Alerts → critical-alerts SNS Topic
- High CPU (>80%)
- High Memory (>85%)
- High Error Count (>10/5min)
- High Disk (>90%)
- High DB Connections (>80)
- High Queue Depth (>100)

### Warning Alerts → warning-alerts SNS Topic
- High API Latency (>1000ms)
- High Network (>1MB/s)
- Low Request Count (<10/5min)
- Low Cache Hit Rate (<70%)

## Event Automation

### Scheduled Events
- Health check (every 5 minutes)
- Metric collection (every 1 minute)
- Daily cleanup (midnight UTC)
- Weekly report (Monday 9am UTC)

### Event-Driven
- CloudWatch alarm state changes → SNS
- EC2 state changes → SNS
- Application errors (CRITICAL/HIGH) → SNS
- Deployment events → SNS

## Data Flow

1. **Collection**: Applications emit metrics and logs
2. **Ingestion**: CloudWatch and Prometheus collect data
3. **Processing**: Metric filters, aggregations, transformations
4. **Alerting**: Alarms trigger on thresholds
5. **Notification**: SNS sends alerts to subscribers
6. **Automation**: EventBridge triggers automated responses
7. **Visualization**: Dashboards display real-time data

## High Availability Considerations

- Multiple SNS topics for alert routing
- Composite alarms for complex conditions
- Redundant monitoring (CloudWatch + Prometheus)
- Event replay capability (EventBridge)
- Log retention policies

## Cost Optimization (Production)

- Appropriate log retention (7-14 days)
- Metric filtering to reduce noise
- Alarm consolidation
- Dashboard optimization
- Prometheus data retention tuning
