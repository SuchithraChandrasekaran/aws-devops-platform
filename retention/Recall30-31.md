# Days 30 to 31 Command Recall

---

## Day 30 - Build event-driven remediation workflows with EventBridge + Lambda

```bash
# Create custom event bus
aws --endpoint-url=http://localhost:4566 events create-event-bus \
  --name remediation-bus

# Rule 1: High CPU → scale up Lambda
aws --endpoint-url=http://localhost:4566 events put-rule \
  --name "HighCPURemediation" \
  --event-bus-name remediation-bus \
  --event-pattern '{
    "source": ["myapp.monitoring"],
    "detail-type": ["MetricAlarm"],
    "detail": { "alarmName": ["HighCPU"], "state": ["ALARM"] }
  }' \
  --state ENABLED

# Rule 2: Security finding → isolate instance
aws --endpoint-url=http://localhost:4566 events put-rule \
  --name "SecurityRemediation" \
  --event-bus-name remediation-bus \
  --event-pattern '{
    "source": ["aws.guardduty"],
    "detail-type": ["GuardDuty Finding"]
  }' \
  --state ENABLED

# Rule 3: Untagged resource → auto-tag Lambda
aws --endpoint-url=http://localhost:4566 events put-rule \
  --name "UntaggedResource" \
  --event-bus-name remediation-bus \
  --event-pattern '{
    "source": ["aws.ec2"],
    "detail-type": ["EC2 Instance State-change Notification"],
    "detail": { "state": ["running"] }
  }' \
  --state ENABLED

# Wire all rules to their Lambda targets
aws --endpoint-url=http://localhost:4566 events put-targets \
  --rule "HighCPURemediation" \
  --event-bus-name remediation-bus \
  --targets Id=1,Arn=arn:aws:lambda:us-east-1:000000000000:function:auto-stop-resources

aws --endpoint-url=http://localhost:4566 events put-targets \
  --rule "SecurityRemediation" \
  --event-bus-name remediation-bus \
  --targets Id=1,Arn=arn:aws:lambda:us-east-1:000000000000:function:security-remediation

aws --endpoint-url=http://localhost:4566 events put-targets \
  --rule "UntaggedResource" \
  --event-bus-name remediation-bus \
  --targets Id=1,Arn=arn:aws:lambda:us-east-1:000000000000:function:auto-tag

# Test full workflow - fire a simulated event
aws --endpoint-url=http://localhost:4566 events put-events \
  --entries '[{
    "Source": "myapp.monitoring",
    "DetailType": "MetricAlarm",
    "Detail": "{\"alarmName\": \"HighCPU\", \"state\": \"ALARM\"}",
    "EventBusName": "remediation-bus"
  }]'

# Verify Lambda was triggered - check logs
aws --endpoint-url=http://localhost:4566 logs get-log-events \
  --log-group-name "/aws/lambda/auto-stop-resources" \
  --log-stream-name $(aws --endpoint-url=http://localhost:4566 logs describe-log-streams \
    --log-group-name "/aws/lambda/auto-stop-resources" \
    --query 'logStreams[-1].logStreamName' --output text)
```

---

## Day 31 - Implement Docker Compose scaling (simulates EC2 Auto Scaling)

```yaml
# docker-compose.yml with scaling
version: '3.8'
services:
  app:
    image: my-app:latest
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
      restart_policy:
        condition: on-failure
    ports:
      - "3000-3010:3000"

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - app
```

```nginx
# nginx.conf - load balancer across scaled app containers
events {}
http {
  upstream app_cluster {
    server app_1:3000;
    server app_2:3000;
    server app_3:3000;
  }
  server {
    listen 80;
    location / {
      proxy_pass http://app_cluster;
    }
  }
}
```

```bash
# Start with 2 replicas
docker-compose up -d --scale app=2

# Scale up to 4 (simulates Auto Scaling out)
docker-compose up -d --scale app=4

# Scale down to 1 (simulates Auto Scaling in)
docker-compose up -d --scale app=1

# Check running instances
docker-compose ps

# Monitor CPU of each container (simulate CloudWatch metrics)
docker stats --no-stream

# Simulate load to trigger scale-up decision
for i in {1..100}; do curl -s http://localhost:80 > /dev/null; done

# View logs across all app instances
docker-compose logs -f app

# Health check all replicas
docker-compose ps | grep app | awk '{print $1}' | \
  xargs -I{} docker inspect {} --format '{{.State.Health.Status}}'

# Tear down
docker-compose down
```

---
