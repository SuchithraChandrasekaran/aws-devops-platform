# Day 3 - Docker Containerization
# Single-stage build - Simple and Working

FROM node:18-alpine

# Add labels
LABEL maintainer="devops-engineer"
LABEL version="1.0.0"
LABEL description="AWS DevOps Sample App - Day 3"

# Set working directory
WORKDIR /app

# Copy package files first (for better caching)
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy application code
COPY src ./src

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Health check - Fixed to use wget which doesn't hold the port
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/health || exit 1

# Environment variables
ENV NODE_ENV=production \
    PORT=3000

# Start application
CMD ["node", "src/index.js"]
