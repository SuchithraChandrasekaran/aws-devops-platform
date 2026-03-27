const http = require('http');
const { execSync } = require('child_process');

// In-memory metrics store
const metrics = {
  requestCount: 0,
  errorCount: 0,
  totalResponseTime: 0,
  activeConnections: 0
};

// Push metrics to CloudWatch via AWS CLI
function pushMetrics() {
  const avgResponseTime = metrics.requestCount > 0
    ? metrics.totalResponseTime / metrics.requestCount
    : 0;

  const timestamp = new Date().toISOString();

  const metricData = [
    { MetricName: 'RequestCount',   Value: metrics.requestCount,   Unit: 'Count' },
    { MetricName: 'ErrorCount',     Value: metrics.errorCount,     Unit: 'Count' },
    { MetricName: 'AvgResponseTime',Value: avgResponseTime,        Unit: 'Milliseconds' },
    { MetricName: 'ActiveConnections', Value: metrics.activeConnections, Unit: 'Count' }
  ];

  metricData.forEach(m => {
    try {
      execSync(`aws cloudwatch put-metric-data \
        --namespace "aws-devops-platform/app" \
        --metric-name "${m.MetricName}" \
        --value ${m.Value} \
        --unit ${m.Unit} \
        --dimensions Name=AppName,Value=monitoring-demo \
        --region us-east-1`, { stdio: 'pipe' });
      console.log(`[${timestamp}] Pushed ${m.MetricName}: ${m.Value}`);
    } catch (e) {
      console.error(`Failed to push ${m.MetricName}:`, e.message);
    }
  });

  // Reset counters after push
  metrics.requestCount = 0;
  metrics.errorCount = 0;
  metrics.totalResponseTime = 0;
}

// Push every 60 seconds
setInterval(pushMetrics, 60000);

// HTTP server
const server = http.createServer((req, res) => {
  const start = Date.now();
  metrics.requestCount++;
  metrics.activeConnections++;

  // Simulate occasional errors on /error path
  if (req.url === '/error') {
    metrics.errorCount++;
    res.writeHead(500, {'Content-Type': 'application/json'});
    res.end(JSON.stringify({ error: 'Simulated error', status: 500 }));
  } else if (req.url === '/metrics') {
    // Local metrics endpoint - see current counts without waiting for CloudWatch
    res.writeHead(200, {'Content-Type': 'application/json'});
    res.end(JSON.stringify({
      ...metrics,
      avgResponseTime: metrics.requestCount > 0
        ? metrics.totalResponseTime / metrics.requestCount
        : 0
    }));
  } else {
    // Simulate variable response time
    const delay = Math.floor(Math.random() * 100);
    setTimeout(() => {
      res.writeHead(200, {'Content-Type': 'application/json'});
      res.end(JSON.stringify({
        message: 'Hello from monitored app',
        responseTime: `${Date.now() - start}ms`
      }));
    }, delay);
  }

  metrics.totalResponseTime += (Date.now() - start);
  metrics.activeConnections--;
});

server.listen(3000, () => {
  console.log('Monitored app running on port 3000');
  console.log('Metrics will push to CloudWatch every 60 seconds');
});
