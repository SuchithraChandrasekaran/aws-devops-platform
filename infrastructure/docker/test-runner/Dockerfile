FROM node:18-alpine

# Install test dependencies
RUN apk add --no-cache bash curl git

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy application code
COPY . .

# Run tests by default
CMD ["npm", "test"]