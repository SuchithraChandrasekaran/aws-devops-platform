#!/usr/bin/env python3
"""
Application with centralized CloudWatch logging

"""

from flask import Flask, jsonify, request
import boto3
from datetime import datetime
import time

app = Flask(__name__)

logs_client = boto3.client(
    'logs',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

def send_log(log_group, stream, message, level='INFO'):
    """Send log to CloudWatch"""
    try:
        logs_client.put_log_events(
            logGroupName=log_group,
            logStreamName=stream,
            logEvents=[{
                'timestamp': int(time.time() * 1000),
                'message': f"[{level}] {message}"
            }]
        )
    except Exception as e:
        print(f"Log error: {e}")

@app.route('/')
def index():
    send_log('/aws/api/myapp', 'api-stream', 'GET / endpoint called', 'INFO')
    return jsonify({'status': 'ok', 'service': 'myapp'})

@app.route('/health')
def health():
    send_log('/aws/api/myapp', 'api-stream', 'Health check performed', 'INFO')
    return jsonify({'status': 'healthy'})

@app.route('/error')
def trigger_error():
    send_log('/aws/errors/myapp', 'error-stream', 'Intentional error triggered', 'ERROR')
    return jsonify({'status': 'error'}), 500

@app.before_request
def log_request():
    send_log('/aws/application/myapp', 'app-stream', 
             f"Request: {request.method} {request.path}", 'INFO')

if __name__ == '__main__':
    send_log('/aws/application/myapp', 'app-stream', 
             'Application starting up', 'INFO')
    print("Application with centralized logging started")
    app.run(host='0.0.0.0', port=5001, debug=True)
