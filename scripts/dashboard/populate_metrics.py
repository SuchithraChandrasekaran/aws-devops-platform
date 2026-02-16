#!/usr/bin/env python3
"""
Dashboard Metrics Population Script
Day 18 - Populate dashboard with realistic test data
"""

import boto3
import random
import time
from datetime import datetime, timezone

cloudwatch = boto3.client(
    'cloudwatch',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

def send_metric(namespace, metric_name, value, unit='None'):
    """Send a single metric to CloudWatch"""
    try:
        cloudwatch.put_metric_data(
            Namespace=namespace,
            MetricData=[{
                'MetricName': metric_name,
                'Value': value,
                'Timestamp': datetime.now(timezone.utc),
                'Unit': unit
            }]
        )
        return True
    except Exception as e:
        print(f"Error sending {metric_name}: {e}")
        return False

def generate_realistic_metrics():
    """Generate realistic metric values"""
    return {
        'CPUUtilization': random.uniform(30, 85),
        'MemoryUtilization': random.uniform(40, 80),
        'DiskUtilization': random.uniform(50, 75),
        'NetworkThroughput': random.uniform(100000, 900000),
        'RequestCount': random.randint(50, 200),
        'DatabaseConnections': random.randint(20, 70),
        'CacheHitRate': random.uniform(75, 95),
        'QueueDepth': random.randint(10, 80)
    }

def generate_log_metrics():
    """Generate log-based metrics"""
    return {
        'ErrorCountFromLogs': random.randint(0, 15),
        'APIResponseTime': random.uniform(100, 800)
    }

if __name__ == '__main__':
    print("="*60)
    print("Dashboard Metrics Population - Day 18")
    print("="*60)
    print()
    
    print("Sending 30 data points over 5 minutes...")
    print("This will populate the dashboard with realistic data")
    print()
    
    for i in range(30):
        print(f"Iteration {i+1}/30", end=" - ")
        
        # Generate and send app metrics
        app_metrics = generate_realistic_metrics()
        success_count = 0
        
        for metric_name, value in app_metrics.items():
            unit = 'Percent' if 'Utilization' in metric_name or 'Rate' in metric_name else 'Count'
            if send_metric('MyApp/Metrics', metric_name, value, unit):
                success_count += 1
        
        # Generate and send log metrics
        log_metrics = generate_log_metrics()
        for metric_name, value in log_metrics.items():
            unit = 'Count' if 'Count' in metric_name else 'Milliseconds'
            if send_metric('MyApp/Logs', metric_name, value, unit):
                success_count += 1
        
        print(f"✓ {success_count} metrics sent")
        
        # Wait 10 seconds between iterations
        if i < 29:  # Don't wait after last iteration
            time.sleep(10)
    
    print()
    print("="*60)
    print("Dashboard population complete!")
    print("="*60)
    print()
    print("View your dashboard:")
    print("aws --endpoint-url=http://localhost:4566 cloudwatch get-dashboard \\")
    print("  --dashboard-name operations-dashboard")
