#!/usr/bin/env python3
"""
Security Finding Simulator - Day 26
Simulate GuardDuty findings to trigger Lambda remediation
"""

import boto3
import json
from datetime import datetime

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

def simulate_sg_finding():
    """Simulate security group finding"""
    finding = {
        'version': '0',
        'id': '1234567890',
        'detail-type': 'GuardDuty Finding',
        'source': 'aws.guardduty',
        'detail': {
            'type': 'UnauthorizedAccess:EC2/SSHBruteForce',
            'severity': 'HIGH',
            'resource': {
                'instanceDetails': {
                    'instanceId': 'i-1234567890abcdef0'
                }
            }
        }
    }
    
    print("Simulating Security Group finding...")
    invoke_lambda('myapp-sg-remediation', finding)

def simulate_iam_finding():
    """Simulate IAM policy finding"""
    finding = {
        'version': '0',
        'id': '0987654321',
        'detail-type': 'GuardDuty Finding',
        'source': 'aws.guardduty',
        'detail': {
            'type': 'Policy:IAMUser/RootCredentialUsage',
            'severity': 'HIGH',
            'resource': {
                'accessKeyDetails': {
                    'userName': 'test-user'
                }
            }
        }
    }
    
    print("Simulating IAM finding...")
    invoke_lambda('myapp-iam-remediation', finding)

def simulate_s3_finding():
    """Simulate S3 bucket finding"""
    finding = {
        'version': '0',
        'id': '1122334455',
        'detail-type': 'Security Hub Findings - Imported',
        'source': 'aws.securityhub',
        'detail': {
            'type': 'Effects:S3/PublicBucketExposed',
            'severity': 'CRITICAL',
            'resource': {
                's3BucketDetails': {
                    'name': 'test-bucket'
                }
            }
        }
    }
    
    print("Simulating S3 finding...")
    invoke_lambda('myapp-s3-remediation', finding)

def invoke_lambda(function_name, event):
    """Invoke Lambda function directly"""
    try:
        response = lambda_client.invoke(
            FunctionName=function_name,
            InvocationType='RequestResponse',
            Payload=json.dumps(event)
        )
        
        result = json.loads(response['Payload'].read())
        print(f"  Lambda Response: {result}")
        print(f"  Status: SUCCESS")
        
    except Exception as e:
        print(f"  Error invoking Lambda: {e}")

if __name__ == '__main__':
    print("="*70)
    print("Security Finding Simulator - Day 26")
    print("="*70)
    print()
    
    simulate_sg_finding()
    print()
    
    simulate_iam_finding()
    print()
    
    simulate_s3_finding()
    print()
    
    print("="*70)
    print("Simulation complete")
    print("="*70)
