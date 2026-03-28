const http = require('http');
const { execSync } = require('child_process');

const APP_LOG_GROUP = '/aws-devops-platform/app';
const ERROR_LOG_GROUP = '/aws-devops-platform/errors';
const ACCESS_LOG_GROUP = '/aws-devops-platform/access';
const LOG_STREAM = `app-${new Date().toISOString().split('T')[0]}`;
const REGION = 'us-east-1';

// Create log streams
function createLogStream(logGroup, streamName) {
  try {
    execSync(`aws logs create-log-stream \
      --log-group-name "${logGroup}" \
      --log-stream-name "${streamName}" \
      --region ${REGION}`, { stdio: 'pipe' });
  } catch (e) {
    // Stream may already exist
  }
}

// Push a log event to CloudWatch
function pushLog(logGroup, message) {
  try {
    const timestamp = Date.now();
    const logEvent = JSON.stringify([{
      timestamp,
      message: typeof message === 'object' ? JSON.stringify(message) : message
    }]);

    execSync(`aws logs put-log-events \
      --log-group-name "${logGroup}" \
      --log-stream-name "${LOG_STREAM}" \
      --log-events '${logEvent.replace(/'/g, "'\\''")}' \
      --region ${REGION}`, { stdio: 'pipe' });
  } catch (e) {
    console.error('Failed to push log:', e.message);
  }
}

// Initialize log streams
createLogStream(APP_LOG_GROUP, LOG_STREAM);
createLogStream(ERROR_LOG_GROUP, LOG_STREAM);
createLogStream(ACCESS_LOG_GROUP, LOG_STREAM);

console.log('Log streams created, starting server...');

const server = http.createServer((req, res) => {
  const start = Date.now();
  const requestId = Math.random().toString(36).substr(2, 9);

  // Access log - every request
  pushLog(ACCESS_LOG_GROUP, {
    type: 'access',
    requestId,
    method: req.method,
    path: req.url,
    timestamp: new Date().toISOString()
  });

  if (req.url === '/error') {
    const errorMsg = {
      type: 'error',
      requestId,
      message: 'Simulated application error',
      path: req.url,
      timestamp: new Date().toISOString()
    };

    pushLog(ERROR_LOG_GROUP, errorMsg);
    console.error(JSON.stringify(errorMsg));

    res.writeHead(500, {'Content-Type': 'application/json'});
    res.end(JSON.stringify({ error: 'Internal server error', requestId }));

  } else if (req.url === '/slow') {
    setTimeout(() => {
      const duration = Date.now() - start;
      const appLog = {
        type: 'slow_request',
        requestId,
        path: req.url,
        durationMs: duration,
        timestamp: new Date().toISOString()
      };

      pushLog(APP_LOG_GROUP, appLog);
      console.log(JSON.stringify(appLog));

      res.writeHead(200, {'Content-Type': 'application/json'});
      res.end(JSON.stringify({ message: 'Slow response', durationMs: duration, requestId }));
    }, 500);

  } else {
    const duration = Date.now() - start;
    const appLog = {
      type: 'request',
      requestId,
      path: req.url,
      durationMs: duration,
      status: 200,
      timestamp: new Date().toISOString()
    };

    pushLog(APP_LOG_GROUP, appLog);
    console.log(JSON.stringify(appLog));

    res.writeHead(200, {'Content-Type': 'application/json'});
    res.end(JSON.stringify({ message: 'OK', requestId, durationMs: duration }));
  }
});

server.listen(3000, () => {
  console.log('Log aggregation app running on port 3000');
});
