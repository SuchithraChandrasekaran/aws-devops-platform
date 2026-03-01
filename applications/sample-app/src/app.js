const express = require('express');
const os = require('os');
const app = express();

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Docker!',
    hostname: os.hostname(),
    day: '3',
    task: 'Containerization complete!',
    project: 'AWS DevOps Platform',
    environment: process.env.NODE_ENV || 'production',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    hostname: os.hostname(),
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

app.get('/ready', (req, res) => {
  res.json({
    ready: true,
    timestamp: new Date().toISOString()
  });
});

app.get('/api/info', (req, res) => {
  res.json({
    version: '1.0.0',
    endpoints: ['/', '/health', '/ready', '/api/info']
  });
});

app.get('/metrics', (req, res) => {
  res.json({
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    memory: process.memoryUsage()
  });
});

app.use((req, res) => {
  res.status(404).json({ error: 'Not Found' });
});

module.exports = app;
