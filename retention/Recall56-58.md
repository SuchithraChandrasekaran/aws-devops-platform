# Day 82 Recall - D56, D57 & D58

---

## D56 - NGINX SSL/TLS with Let's Encrypt

```bash
# Install Certbot
sudo yum install -y certbot python3-certbot-nginx

# Obtain SSL cert
sudo certbot --nginx -d <domain> -d www.<domain>

# Test auto-renewal
sudo certbot renew --dry-run

# Cron for auto-renewal
echo "0 12 * * * root certbot renew --quiet" | sudo tee /etc/cron.d/certbot

# Test config and reload
sudo nginx -t && sudo systemctl reload nginx

# Verify HTTPS
curl -I https://<domain>

# Check cert expiry
sudo certbot certificates
```

```nginx
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name <domain>;
    return 301 https://$host$request_uri;
}

# HTTPS block
server {
    listen 443 ssl;
    server_name <domain>;
    ssl_certificate     /etc/letsencrypt/live/<domain>/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/<domain>/privkey.pem;
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## D57 - Application-level Monitoring

```bash
# Push custom metrics
aws cloudwatch put-metric-data \
  --namespace "<namespace>" \
  --metric-name "RequestCount" --value 1 --unit Count \
  --dimensions Name=Environment,Value=<env>

aws cloudwatch put-metric-data \
  --namespace "<namespace>" \
  --metric-name "ResponseTimeMs" --value 200 --unit Milliseconds \
  --dimensions Name=Environment,Value=<env>

aws cloudwatch put-metric-data \
  --namespace "<namespace>" \
  --metric-name "ErrorCount" --value 0 --unit Count \
  --dimensions Name=Environment,Value=<env>

# Alarm on slow response
aws cloudwatch put-metric-alarm \
  --alarm-name "<alarm-name>" \
  --namespace <namespace> --metric-name ResponseTimeMs \
  --dimensions Name=Environment,Value=<env> \
  --statistic Average --period 60 --threshold 1000 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions <sns-topic-arn>
```

```javascript
// Express middleware - emit metrics per request
const { CloudWatchClient, PutMetricDataCommand } = require("@aws-sdk/client-cloudwatch");
const cw = new CloudWatchClient({ region: "<region>" });

app.use(async (req, res, next) => {
  const start = Date.now();
  res.on("finish", async () => {
    const ms = Date.now() - start;
    const dims = [{ Name: "Environment", Value: "<env>" }];
    await cw.send(new PutMetricDataCommand({
      Namespace: "<namespace>",
      MetricData: [
        { MetricName: "RequestCount", Value: 1, Unit: "Count", Dimensions: dims },
        { MetricName: "ResponseTimeMs", Value: ms, Unit: "Milliseconds", Dimensions: dims },
        ...(res.statusCode >= 500
          ? [{ MetricName: "ErrorCount", Value: 1, Unit: "Count", Dimensions: dims }]
          : [])
      ]
    }));
  });
  next();
});
```

---

## D58 - Log Aggregation and Analysis

```bash
# Create log group with retention
aws logs create-log-group --log-group-name "<log-group>"
aws logs put-retention-policy \
  --log-group-name "<log-group>" \
  --retention-in-days 7

# Create log stream
aws logs create-log-stream \
  --log-group-name "<log-group>" \
  --log-stream-name "<stream-name>"

# Put log events
aws logs put-log-events \
  --log-group-name "<log-group>" \
  --log-stream-name "<stream-name>" \
  --log-events timestamp=$(date +%s000),message="ERROR: something failed"

# Metric filter - count errors
aws logs put-metric-filter \
  --log-group-name "<log-group>" \
  --filter-name "ErrorCount" \
  --filter-pattern "ERROR" \
  --metric-transformations \
    metricName=ErrorCount,metricNamespace=<namespace>,metricValue=1

# Logs Insights query
aws logs start-query \
  --log-group-name "<log-group>" \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 20'

# Get query results
aws logs get-query-results --query-id <query-id>

# Tail logs live
aws logs tail <log-group> --follow
```

---
