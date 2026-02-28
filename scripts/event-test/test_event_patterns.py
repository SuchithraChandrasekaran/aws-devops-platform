#!/usr/bin/env python3
"""
Event Pattern Tester - Day 30
Test EventBridge patterns and Lambda triggers
"""

import boto3
import json
import time

events = boto3.client(
    'events',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

lambda_client = boto3.client(
    'lambda',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

def test_ec2_state_change():
    """Test EC2 state change event"""
    print("\nTest 1: EC2 State Change Event")
    print("-" * 70)
    
    event = {
        'version': '0',
        'id': 'test-ec2-state',
        'detail-type': 'EC2 Instance State-change Notification',
        'source': 'aws.ec2',
        'detail': {
            'instance-id': 'i-test123',
            'state': 'stopped'
        }
    }
    
    try:
        response = events.put_events(Entries=[event])
        print(f"  Event sent: {response['FailedEntryCount']} failed")
        print(f"  Expected: EC2 handler Lambda triggered")
    except Exception as e:
        print(f"  Error: {e}")

def test_s3_bucket_created():
    """Test S3 bucket creation event"""
    print("\nTest 2: S3 Bucket Creation Event")
    print("-" * 70)
    
    event = {
        'version': '0',
        'id': 'test-s3-create',
        'detail-type': 'AWS API Call via CloudTrail',
        'source': 'aws.s3',
        'detail': {
            'eventName': 'CreateBucket',
            'requestParameters': {
                'bucketName': 'test-new-bucket'
            }
        }
    }
    
    try:
        response = events.put_events(Entries=[event])
        print(f"  Event sent: {response['FailedEntryCount']} failed")
        print(f"  Expected: S3 security handler triggered")
    except Exception as e:
        print(f"  Error: {e}")

def test_iam_policy_change():
    """Test IAM policy change event"""
    print("\nTest 3: IAM Policy Change Event")
    print("-" * 70)
    
    event = {
        'version': '0',
        'id': 'test-iam-policy',
        'detail-type': 'AWS API Call via CloudTrail',
        'source': 'aws.iam',
        'detail': {
            'eventName': 'AttachUserPolicy',
            'userIdentity': {
                'principalId': 'unauthorized-user'
            },
            'requestParameters': {
                'userName': 'test-user',
                'policyArn': 'arn:aws:iam::aws:policy/AdministratorAccess'
            }
        }
    }
    
    try:
        response = events.put_events(Entries=[event])
        print(f"  Event sent: {response['FailedEntryCount']} failed")
        print(f"  Expected: IAM audit handler triggered")
    except Exception as e:
        print(f"  Error: {e}")

def test_alarm_state_change():
    """Test CloudWatch alarm event"""
    print("\nTest 4: CloudWatch Alarm State Change")
    print("-" * 70)
    
    # Directly invoke Lambda with transformed input
    event = {
        'alarm_name': 'high-cpu-utilization',
        'new_state': 'ALARM',
        'reason': 'Threshold crossed: 1 out of 1 datapoints'
    }
    
    try:
        response = lambda_client.invoke(
            FunctionName='myapp-alarm-handler',
            InvocationType='RequestResponse',
            Payload=json.dumps(event)
        )
        result = json.loads(response['Payload'].read())
        print(f"  Lambda invoked: {result.get('statusCode')}")
        print(f"  Response: {result.get('body')}")
    except Exception as e:
        print(f"  Error: {e}")

def run_tests():
    """Run all event pattern tests"""
    print("="*70)
    print("EventBridge Pattern Tests - Day 30")
    print("="*70)
    
    test_ec2_state_change()
    time.sleep(1)
    
    test_s3_bucket_created()
    time.sleep(1)
    
    test_iam_policy_change()
    time.sleep(1)
    
    test_alarm_state_change()
    
    print("\n" + "="*70)
    print("Event Pattern Tests Complete")
    print("="*70)
    print("\nNote: Check Lambda logs to verify handlers were triggered")

if __name__ == '__main__':
    run_tests()
