# Day 81 Recall - D54 & D55

---

## D54 - Billing Alarms and Budgets

```bash
# Billing alarm at $1
aws cloudwatch put-metric-alarm \
  --alarm-name "Billing-1USD" \
  --namespace AWS/Billing \
  --metric-name EstimatedCharges \
  --dimensions Name=Currency,Value=USD \
  --statistic Maximum --period 86400 --threshold 1 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:us-east-1:<account-id>:myapp-alerts

# Billing alarm at $5
aws cloudwatch put-metric-alarm \
  --alarm-name "Billing-5USD" \
  --namespace AWS/Billing \
  --metric-name EstimatedCharges \
  --dimensions Name=Currency,Value=USD \
  --statistic Maximum --period 86400 --threshold 5 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:us-east-1:<account-id>:myapp-alerts

# Create monthly budget ($10 limit, alert at 80%)
aws budgets create-budget \
  --account-id <account-id> \
  --budget '{
    "BudgetName": "MyApp-Monthly",
    "BudgetLimit": { "Amount": "10", "Unit": "USD" },
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST"
  }' \
  --notifications-with-subscribers '[{
    "Notification": {
      "NotificationType": "ACTUAL",
      "ComparisonOperator": "GREATER_THAN",
      "Threshold": 80,
      "ThresholdType": "PERCENTAGE"
    },
    "Subscribers": [{"SubscriptionType": "EMAIL", "Address": "you@example.com"}]
  }]'

# Check current month spend
aws ce get-cost-and-usage \
  --time-period Start=$(date -u +%Y-%m-01),End=$(date -u +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost
```

---

## D55 - Blue-Green Deployment with Docker

```bash
# Build both versions
docker build -t my-app:v1 .
docker build -t my-app:v2 .

# Run blue (live) and green (new)
docker run -d --name blue  -p 3001:3000 my-app:v1
docker run -d --name green -p 3002:3000 my-app:v2

# Test green before switching
curl http://localhost:3002/health

# Switch NGINX to green
sudo sed -i 's/3001/3002/' /etc/nginx/conf.d/myapp.conf
sudo nginx -t && sudo systemctl reload nginx

# Verify green is live
curl http://localhost:80

# Clean up blue
docker stop blue && docker rm blue

# Rollback to blue if needed
sudo sed -i 's/3002/3001/' /etc/nginx/conf.d/myapp.conf
sudo nginx -t && sudo systemctl reload nginx
docker stop green && docker rm green
```

```nginx
# /etc/nginx/conf.d/myapp.conf
upstream active {
    server localhost:3001;
}
server {
    listen 80;
    location / { proxy_pass http://active; }
}
```

---
