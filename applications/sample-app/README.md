# AWS DevOps Platform - Sample Application

Simple Node.js Express API created on Day 2 of the AWS DevOps learning.

## Features

- Express.js REST API
- Health check endpoint
- Security with Helmet
- CORS enabled
- Request logging with Morgan
- Environment configuration
- Graceful shutdown
- Error handling

## Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Welcome message |
| `/health` | GET | Health check |
| `/api/v1/status` | GET | Service status |
| `/info` | GET | Application info |

## Quick Start
```bash
# Install dependencies
npm install

# Run in development mode
npm run dev

# Run in production mode
npm start

# Run tests
npm test
```

## Environment Variables

See `.env.example` for required environment variables.

## Day 2 tasks

- Complete VPC setup (10.0.0.0/16)
- 2 subnets (public & private)
- Internet Gateway configured
- Security groups created
- Node.js application deployed

