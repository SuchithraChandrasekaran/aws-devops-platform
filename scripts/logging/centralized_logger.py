#!/usr/bin/env python3
"""
Centralized Logger for CloudWatch Logs
Day 16 - Log aggregation implementation
"""

import boto3
from datetime import datetime
import json
import time

class CloudWatchLogger:
    def __init__(self, log_group, log_stream):
        self.client = boto3.client(
            'logs',
            endpoint_url='http://localhost:4566',
            region_name='us-east-1',
            aws_access_key_id='test',
            aws_secret_access_key='test'
        )
        self.log_group = log_group
        self.log_stream = log_stream
        self.sequence_token = None
    
    def put_log(self, message, level='INFO'):
        """Send log event to CloudWatch"""
        timestamp = int(time.time() * 1000)
        
        log_event = {
            'logGroupName': self.log_group,
            'logStreamName': self.log_stream,
            'logEvents': [
                {
                    'timestamp': timestamp,
                    'message': f"[{level}] {message}"
                }
            ]
        }
        
        if self.sequence_token:
            log_event['sequenceToken'] = self.sequence_token
        
        try:
            response = self.client.put_log_events(**log_event)
            self.sequence_token = response.get('nextSequenceToken')
            print(f"Log sent: [{level}] {message}")
        except Exception as e:
            print(f"Error sending log: {e}")
    
    def info(self, message):
        self.put_log(message, 'INFO')
    
    def error(self, message):
        self.put_log(message, 'ERROR')
    
    def warning(self, message):
        self.put_log(message, 'WARNING')

if __name__ == '__main__':
    print("========================================")
    print("CloudWatch Centralized Logger - Day 16")
    print("========================================\n")
    
    # Create loggers for different services
    app_logger = CloudWatchLogger('/aws/application/myapp', 'app-stream')
    api_logger = CloudWatchLogger('/aws/api/myapp', 'api-stream')
    error_logger = CloudWatchLogger('/aws/errors/myapp', 'error-stream')
    
    # Log some events
    app_logger.info("Application started successfully")
    app_logger.info("Loading configuration from SSM")
    
    api_logger.info("API endpoint /health called")
    api_logger.info("API endpoint /users called")
    
    error_logger.error("Database connection timeout")
    error_logger.warning("High memory usage detected")
    
    time.sleep(1)
    
    app_logger.info("Application running normally")
    
    print("\nLogs sent to CloudWatch")
