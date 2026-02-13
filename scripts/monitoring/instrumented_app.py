#!/usr/bin/env python3
"""
Sample application instrumented with CloudWatch metrics
Day 15 - Application monitoring
"""

from flask import Flask, jsonify
import boto3
from datetime import datetime
import time
import random

app = Flask(__name__)

# CloudWatch client
cloudwatch = boto3.client(
    'cloudwatch',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

def send_metric(metric_name, value, unit='Count'):
    """Send metric to CloudWatch"""
    try:
        cloudwatch.put_metric_data(
            Namespace='MyApp/Performance',
            MetricData=[{
                'MetricName': metric_name,
                'Value': value,
                'Unit': unit,
                'Timestamp': datetime.utcnow(),
                'Dimensions': [
                    {'Name': 'Environment', 'Value': 'dev'},
                    {'Name': 'Service', 'Value': 'api'}
                ]
            }]
        )
    except Exception as e:
        print(f"Metric error: {e}")

@app.route('/')
def index():
    start_time = time.time()
    
    # Simulate some work
    time.sleep(random.uniform(0.01, 0.1))
    
    # Calculate response time
    response_time = (time.time() - start_time) * 1000
    
    # Send metrics
    send_metric('RequestCount', 1, 'Count')
    send_metric('ResponseTime', response_time, 'Milliseconds')
    
    return jsonify({
        'status': 'success',
        'message': 'Application instrumented with CloudWatch',
        'response_time_ms': round(response_time, 2)
    })

@app.route('/health')
def health():
    send_metric('HealthCheck', 1, 'Count')
    return jsonify({'status': 'healthy'})

@app.route('/error')
def error():
    send_metric('ErrorCount', 1, 'Count')
    return jsonify({'status': 'error', 'message': 'Simulated error'}), 500

if __name__ == '__main__':
    print("Starting instrumented application...")
    print("Metrics namespace: MyApp/Performance")
    app.run(host='0.0.0.0', port=5000, debug=True)
