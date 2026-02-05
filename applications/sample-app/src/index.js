const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'Hello from Docker!',
    day: '3',
    task: 'Containerization complete!',
    project: 'AWS DevOps Platform',
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString()
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// API info endpoint
app.get('/api/info', (req, res) => {
  res.json({
    version: '1.0.0',
    name: 'AWS DevOps Sample App',
    description: 'Demo application',
    endpoints: [
      { path: '/', method: 'GET', description: 'Welcome message' },
      { path: '/health', method: 'GET', description: 'Health check' },
      { path: '/api/info', method: 'GET', description: 'API information' }
    ]
  });
});

// Metrics endpoint
app.get('/metrics', (req, res) => {
  res.json({ 
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    memory: process.memoryUsage(),
    platform: process.platform,
    nodeVersion: process.version
  });
});

// Ready check endpoint
app.get('/ready', (req, res) => {
  res.json({ 
    ready: true,
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ 
    error: 'Not Found',
    path: req.path,
    message: 'The requested endpoint does not exist'
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({ 
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'production' ? 'Something went wrong' : err.message
  });
});

// Only start the server if this file is run directly (not imported for testing)
if (require.main === module) {
  app.listen(PORT, '0.0.0.0', () => {
    console.log('='.repeat(50));
    console.log('AWS DevOps Platform - Sample Application');
    console.log('='.repeat(50));
    console.log(`Day: 3 - Docker Containerization`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`Server running on port ${PORT}`);
    console.log(`Health check: http://localhost:${PORT}/health`);
    console.log('='.repeat(50));
  });
}

// Export app for testing
module.exports = app;
