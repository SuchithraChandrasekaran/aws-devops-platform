# Days 44 to 46 Command Recall

---

## Day 44 - RDS automated backups + snapshots

```bash
# Verify automated backups are enabled
aws rds describe-db-instances \
  --db-instance-identifier myapp-db \
  --query 'DBInstances[0].{BackupRetention:BackupRetentionPeriod,BackupWindow:PreferredBackupWindow}'

# Modify backup retention (7 days) and window
aws rds modify-db-instance \
  --db-instance-identifier myapp-db \
  --backup-retention-period 7 \
  --preferred-backup-window "02:00-03:00" \
  --apply-immediately

# List automated backups
aws rds describe-db-snapshots \
  --db-instance-identifier myapp-db \
  --snapshot-type automated \
  --query 'DBSnapshots[].{ID:DBSnapshotIdentifier,Time:SnapshotCreateTime,Status:Status}'

# Create manual snapshot (before major changes)
aws rds create-db-snapshot \
  --db-instance-identifier myapp-db \
  --db-snapshot-identifier myapp-db-manual-$(date +%Y%m%d)

# Wait for snapshot to complete
aws rds wait db-snapshot-completed \
  --db-snapshot-identifier myapp-db-manual-$(date +%Y%m%d)

# List all snapshots
aws rds describe-db-snapshots \
  --db-instance-identifier myapp-db \
  --query 'DBSnapshots[].{ID:DBSnapshotIdentifier,Type:SnapshotType,Status:Status}'

# Restore from snapshot (creates new instance)
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier myapp-db-restored \
  --db-snapshot-identifier myapp-db-manual-$(date +%Y%m%d) \
  --db-instance-class db.t2.micro

# Copy snapshot to another region (DR)
aws rds copy-db-snapshot \
  --source-db-snapshot-identifier myapp-db-manual-$(date +%Y%m%d) \
  --target-db-snapshot-identifier myapp-db-backup-uswest2 \
  --source-region us-east-1 \
  --region us-west-2

# Delete old manual snapshots to save cost
aws rds delete-db-snapshot \
  --db-snapshot-identifier myapp-db-manual-<old-date>
```

---

## Day 45 - S3 lifecycle policies + versioning

```bash
# Enable versioning on bucket
aws s3api put-bucket-versioning \
  --bucket my-app-artifacts \
  --versioning-configuration Status=Enabled

# Verify versioning enabled
aws s3api get-bucket-versioning --bucket my-app-artifacts

# List all versions of objects
aws s3api list-object-versions --bucket my-app-artifacts

# Create lifecycle policy
aws s3api put-bucket-lifecycle-configuration \
  --bucket my-app-artifacts \
  --lifecycle-configuration '{
    "Rules": [
      {
        "ID": "move-to-ia",
        "Status": "Enabled",
        "Filter": { "Prefix": "" },
        "Transitions": [
          {
            "Days": 30,
            "StorageClass": "STANDARD_IA"
          },
          {
            "Days": 90,
            "StorageClass": "GLACIER"
          }
        ],
        "Expiration": {
          "Days": 365
        }
      },
      {
        "ID": "cleanup-old-versions",
        "Status": "Enabled",
        "Filter": { "Prefix": "" },
        "NoncurrentVersionExpiration": {
          "NoncurrentDays": 30
        },
        "NoncurrentVersionTransitions": [
          {
            "NoncurrentDays": 7,
            "StorageClass": "STANDARD_IA"
          }
        ]
      },
      {
        "ID": "cleanup-incomplete-uploads",
        "Status": "Enabled",
        "Filter": { "Prefix": "" },
        "AbortIncompleteMultipartUpload": {
          "DaysAfterInitiation": 7
        }
      }
    ]
  }'

# Verify lifecycle policy
aws s3api get-bucket-lifecycle-configuration --bucket my-app-artifacts

# Restore specific version of an object
aws s3api get-object \
  --bucket my-app-artifacts \
  --key my-app.tar.gz \
  --version-id <version-id> \
  restored-my-app.tar.gz

# Delete a specific version
aws s3api delete-object \
  --bucket my-app-artifacts \
  --key my-app.tar.gz \
  --version-id <version-id>
```

---

## Day 46 - CloudWatch custom metrics for app

```bash
# Push custom metrics from CLI
aws cloudwatch put-metric-data \
  --namespace "MyApp" \
  --metric-name "RequestCount" \
  --value 1 --unit Count \
  --dimensions Name=Environment,Value=prod

aws cloudwatch put-metric-data \
  --namespace "MyApp" \
  --metric-name "ResponseTimeMs" \
  --value 245 --unit Milliseconds \
  --dimensions Name=Environment,Value=prod Name=Endpoint,Value=/api/orders

aws cloudwatch put-metric-data \
  --namespace "MyApp" \
  --metric-name "ErrorCount" \
  --value 0 --unit Count \
  --dimensions Name=Environment,Value=prod

aws cloudwatch put-metric-data \
  --namespace "MyApp" \
  --metric-name "ActiveUsers" \
  --value 12 --unit Count
```

```javascript
// Instrument Node.js app - emit metrics on every request
const { CloudWatchClient, PutMetricDataCommand } = require("@aws-sdk/client-cloudwatch");

const cw = new CloudWatchClient({ region: "us-east-1" });

async function emitMetric(name, value, unit = "Count", dims = []) {
  await cw.send(new PutMetricDataCommand({
    Namespace: "MyApp",
    MetricData: [{
      MetricName: name,
      Value: value,
      Unit: unit,
      Dimensions: dims,
      Timestamp: new Date()
    }]
  }));
}

// Middleware to track every request
app.use(async (req, res, next) => {
  const start = Date.now();
  res.on("finish", async () => {
    const duration = Date.now() - start;
    const dims = [
      { Name: "Environment", Value: "prod" },
      { Name: "Endpoint", Value: req.path }
    ];
    await emitMetric("RequestCount", 1, "Count", dims);
    await emitMetric("ResponseTimeMs", duration, "Milliseconds", dims);
    if (res.statusCode >= 500) {
      await emitMetric("ErrorCount", 1, "Count", dims);
    }
  });
  next();
});
```

```bash
# Verify metrics in CloudWatch
aws cloudwatch list-metrics --namespace "MyApp"

# Query metric stats
aws cloudwatch get-metric-statistics \
  --namespace "MyApp" \
  --metric-name "ResponseTimeMs" \
  --dimensions Name=Environment,Value=prod \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Average Maximum

# Create alarm on response time
aws cloudwatch put-metric-alarm \
  --alarm-name "App-SlowResponse" \
  --namespace MyApp \
  --metric-name ResponseTimeMs \
  --dimensions Name=Environment,Value=prod \
  --statistic Average --period 60 --threshold 1000 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:us-east-1:<account-id>:my-alerts
```

---
