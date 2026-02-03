const express = require('express');

const app = express();

app.get('/', (req, res) => {
	  res.json({
		      message: "Hello"
	  });
});

app.get('/health', (req, res) => {
	  res.json({
		      status: 'healthy',
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

// 404 handler 
app.use((req, res) => {
	res.status(404).json({
	error: 'Not Found'
        });
});

module.exports = app;
