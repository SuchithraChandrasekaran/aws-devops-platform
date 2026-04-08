# Days 19 to 21 Command Recall

---

## Day 19 - Deploy Prometheus + Grafana in Docker (runs on LocalStack EC2)

```yaml
# docker-compose.yml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    depends_on:
      - prometheus
```

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'myapp'
    static_configs:
      - targets: ['host.docker.internal:3001']

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```

```javascript
// Expose /metrics endpoint in Node.js app
const client = require('prom-client');
const express = require('express');
const app = express();

const register = new client.Registry();
client.collectDefaultMetrics({ register });

const requestCount = new client.Counter({
  name: 'myapp_requests_total',
  help: 'Total requests',
  registers: [register]
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.get('/', (req, res) => {
  requestCount.inc();
  res.send('Hello');
});

app.listen(3001);
```

```bash
# Start stack
docker-compose up -d

# Verify Prometheus targets
curl http://localhost:9090/api/v1/targets

# Verify metrics scraped
curl http://localhost:9090/api/v1/query?query=myapp_requests_total

# Grafana UI: http://localhost:3000 (admin/admin)
# Add Prometheus as data source: http://prometheus:9090
```

---

## Day 20 - Create EventBridge rules for automated responses to events

```bash
# Create custom event bus
aws --endpoint-url=http://localhost:4566 events create-event-bus \
  --name my-app-bus

# Create a rule on default bus (scheduled - every 5 mins)
aws --endpoint-url=http://localhost:4566 events put-rule \
  --name "ScheduledRule" \
  --schedule-expression "rate(5 minutes)" \
  --state ENABLED

# Create a rule on custom bus (event pattern match)
aws --endpoint-url=http://localhost:4566 events put-rule \
  --name "AppErrorRule" \
  --event-bus-name my-app-bus \
  --event-pattern '{
    "source": ["myapp"],
    "detail-type": ["AppError"],
    "detail": {
      "severity": ["HIGH"]
    }
  }' \
  --state ENABLED

# Add SNS as target for the rule
aws --endpoint-url=http://localhost:4566 events put-targets \
  --rule "AppErrorRule" \
  --event-bus-name my-app-bus \
  --targets Id=1,Arn=arn:aws:sns:us-east-1:000000000000:my-alerts

# Send a custom event to EventBridge
aws --endpoint-url=http://localhost:4566 events put-events \
  --entries '[{
    "Source": "myapp",
    "DetailType": "AppError",
    "Detail": "{\"severity\": \"HIGH\", \"message\": \"DB connection failed\"}",
    "EventBusName": "my-app-bus"
  }]'

# List rules
aws --endpoint-url=http://localhost:4566 events list-rules \
  --event-bus-name my-app-bus

# List targets for a rule
aws --endpoint-url=http://localhost:4566 events list-targets-by-rule \
  --rule "AppErrorRule" \
  --event-bus-name my-app-bus
```

---

## Day 21 - Complete monitoring stack integration, test all alerts

```bash
# Test CloudWatch alarm triggers SNS
aws --endpoint-url=http://localhost:4566 cloudwatch set-alarm-state \
  --alarm-name "HighCPU" \
  --state-value ALARM \
  --state-reason "Integration test"

# Verify SNS message delivered
aws --endpoint-url=http://localhost:4566 sns list-subscriptions

# Test EventBridge → SNS flow
aws --endpoint-url=http://localhost:4566 events put-events \
  --entries '[{
    "Source": "myapp",
    "DetailType": "AppError",
    "Detail": "{\"severity\": \"HIGH\"}",
    "EventBusName": "my-app-bus"
  }]'

# Check Prometheus metrics are flowing
curl http://localhost:9090/api/v1/query?query=up

# Check all CloudWatch alarms status
aws --endpoint-url=http://localhost:4566 cloudwatch describe-alarms \
  --state-value ALARM

# Check log metric filters are firing
aws --endpoint-url=http://localhost:4566 logs put-log-events \
  --log-group-name "/myapp/dev" \
  --log-stream-name "app-instance-1" \
  --log-events timestamp=$(date +%s000),message="ERROR: test error"

aws --endpoint-url=http://localhost:4566 cloudwatch get-metric-statistics \
  --namespace MyApp \
  --metric-name ErrorCount \
  --start-time $(date -u -d '5 minutes ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Sum

# Full stack health check
docker ps                                         # Prometheus + Grafana running
curl http://localhost:9090/api/v1/targets         # Prometheus scraping app
curl http://localhost:3001/metrics                # App exposing metrics
curl http://localhost:3000                        # Grafana up
```

---
