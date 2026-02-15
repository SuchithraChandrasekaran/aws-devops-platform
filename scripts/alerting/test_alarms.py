#!/usr/bin/env python3
"""
CloudWatch Alarms Testing Script
Test alarm triggering
"""

import boto3
import time
from datetime import datetime

cloudwatch = boto3.client(
    'cloudwatch',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

def put_metric_data(metric_name, value, namespace='MyApp/Metrics'):
    """Send metric data to CloudWatch"""
    try:
        unit = 'Percent' if 'Utilization' in metric_name or 'Rate' in metric_name else 'Count'
        
        cloudwatch.put_metric_data(
            Namespace=namespace,
            MetricData=[{
                'MetricName': metric_name,
                'Value': value,
                'Timestamp': datetime.utcnow(),
                'Unit': unit
            }]
        )
        print(f"Sent: {metric_name} = {value} {unit}")
    except Exception as e:
        print(f"Error: {e}")

def check_alarm_states():
    """Check current state of all alarms"""
    try:
        response = cloudwatch.describe_alarms()
        print("\n" + "="*50)
        print("Current Alarm States")
        print("="*50)
        
        for alarm in response['MetricAlarms']:
            state_emoji = "🔴" if alarm['StateValue'] == 'ALARM' else "🟢" if alarm['StateValue'] == 'OK' else "⚪"
            print(f"{state_emoji} {alarm['AlarmName']}")
            print(f"   State: {alarm['StateValue']}")
            print(f"   Reason: {alarm.get('StateReason', 'N/A')}\n")
            
        # Check composite alarms
        composite_response = cloudwatch.describe_alarms(AlarmTypes=['CompositeAlarm'])
        if composite_response['CompositeAlarms']:
            print("\nComposite Alarms:")
            for alarm in composite_response['CompositeAlarms']:
                state_emoji = "🔴" if alarm['StateValue'] == 'ALARM' else "🟢"
                print(f"{state_emoji} {alarm['AlarmName']}: {alarm['StateValue']}")
                
    except Exception as e:
        print(f"Error checking alarms: {e}")

if __name__ == '__main__':
    print("="*50)
    print("CloudWatch Alarms Testing - Day 17")
    print("="*50)
    print()

    # Test 1: Trigger CPU alarm (threshold 80%)
    print("Test 1: Triggering CPU alarm (>80%)...")
    put_metric_data('CPUUtilization', 85)
    put_metric_data('CPUUtilization', 87)
    time.sleep(2)

    # Test 2: Trigger Memory alarm (threshold 85%)
    print("\nTest 2: Triggering Memory alarm (>85%)...")
    put_metric_data('MemoryUtilization', 90)
    put_metric_data('MemoryUtilization', 92)
    time.sleep(2)

    # Test 3: Trigger Disk alarm (threshold 90%)
    print("\nTest 3: Triggering Disk alarm (>90%)...")
    put_metric_data('DiskUtilization', 95)
    time.sleep(2)

    # Test 4: Trigger Error alarm (threshold 10)
    print("\nTest 4: Triggering Error alarm (>10 errors)...")
    put_metric_data('ErrorCountFromLogs', 15, 'MyApp/Logs')
    time.sleep(2)

    # Test 5: Trigger Latency alarm (threshold 1000ms)
    print("\nTest 5: Triggering Latency alarm (>1000ms)...")
    put_metric_data('APIResponseTime', 1500, 'MyApp/Logs')
    put_metric_data('APIResponseTime', 1200, 'MyApp/Logs')
    time.sleep(2)

    # Test 6: Normal values
    print("\nTest 6: Sending normal values...")
    put_metric_data('CPUUtilization', 45)
    put_metric_data('MemoryUtilization', 60)
    put_metric_data('DiskUtilization', 70)
    put_metric_data('RequestCount', 50)
    put_metric_data('DatabaseConnections', 30)
    put_metric_data('CacheHitRate', 85)
    put_metric_data('QueueDepth', 25)
    time.sleep(2)

    # Test 7: Check all alarm states
    check_alarm_states()

    print("\n" + "="*50)
    print("Alarm testing complete")
    print("="*50)
