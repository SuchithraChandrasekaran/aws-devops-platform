FROM node:18-alpine

RUN apk add --no-cache python3 py3-pip && \
    pip3 install awscli --break-system-packages 2>/dev/null || \
    pip3 install awscli

WORKDIR /app
COPY app.js .
EXPOSE 3000
CMD ["node", "app.js"]
