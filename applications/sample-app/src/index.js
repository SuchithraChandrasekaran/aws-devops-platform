const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    version: '1.0.0'
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.status(200).json({
    message: 'AWS DevOps Platform - Day 2',
    project: 'aws-devops-platform',
    day: '2/95',
    endpoints: {
      health: '/health',
      api: '/api/v1',
      info: '/info'
    }
  });
});

// API v1 routes
app.get('/api/v1/status', (req, res) => {
  res.status(200).json({
    status: 'operational',
    services: {
      database: 'pending',
      cache: 'pending',
      queue: 'pending'
    },
    day: 2,
    vpc: {
      configured: true,
      subnets: 2,
      securityGroups: 2
    }
  });
});

// Info endpoint
app.get('/info', (req, res) => {
  res.status(200).json({
    app: 'AWS DevOps Platform API',
    version: '1.0.0',
    infrastructure: {
      vpc: '10.0.0.0/16',
      publicSubnet: '10.0.1.0/24',
      privateSubnet: '10.0.2.0/24',
      environment: 'LocalStack'
    }
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.url} not found`,
    timestamp: new Date().toISOString()
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message,
    timestamp: new Date().toISOString()
  });
});

// Start server
const server = app.listen(PORT, () => {
  console.log(`
╔══════════════════════════════════════════════════════════╗
║       AWS DevOps Platform - Day 2/95                     ║
║                                                          ║
║       Server running on port ${PORT}                     ║
║       VPC Infrastructure: Complete                       ║
║                                                          ║
║       Endpoints:                                         ║
║       - http://localhost:${PORT}/                        ║
║       - http://localhost:${PORT}/health                  ║
║       - http://localhost:${PORT}/api/v1/status           ║
║       - http://localhost:${PORT}/info                    ║
╚══════════════════════════════════════════════════════════╝
  `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
  });
});

module.exports = app;
