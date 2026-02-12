#!/usr/bin/env python3
"""
CloudWatch Custom Metrics Publisher
Day 15 - PutMetricData API implementation
"""

import boto3
from datetime import datetime
import time
import random

# LocalStack CloudWatch client
cloudwatch = boto3.client(
    'cloudwatch',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

def put_metric(namespace, metric_name, value, unit='Count', dimensions=None):
    """
    Publish single metric using PutMetricData API
    """
    metric_data = {
        'MetricName': metric_name,
        'Value': value,
        'Unit': unit,
        'Timestamp': datetime.utcnow()
    }
    
    if dimensions:
        metric_data['Dimensions'] = dimensions
    
    try:
        response = cloudwatch.put_metric_data(
            Namespace=namespace,
            MetricData=[metric_data]
        )
        print(f"✓ Published: {namespace}/{metric_name} = {value} {unit}")
        return response
    except Exception as e:
        print(f"✗ Error publishing {metric_name}: {str(e)}")
        return None

def publish_app_metrics():
    """
    Simulate application metrics
    """
    namespace = 'MyApp/Performance'
    
    # Request count
    put_metric(namespace, 'RequestCount', random.randint(1, 10), 'Count')
    
    # Response time in milliseconds
    put_metric(namespace, 'ResponseTime', random.uniform(50, 500), 'Milliseconds')
    
    # Error count
    put_metric(namespace, 'ErrorCount', random.randint(0, 3), 'Count')
    
    print()

if __name__ == '__main__':
    print("========================================")
    print("CloudWatch Custom Metrics Publisher")
    print("Day 15 - Publishing metrics to LocalStack")
    print("========================================\n")
    
    # Publish metrics 5 times with 10 second intervals
    for i in range(5):
        print(f"Batch {i+1}/5:")
        publish_app_metrics()
        if i < 4:
            time.sleep(10)
    
    print("✓ Metrics publishing complete")
