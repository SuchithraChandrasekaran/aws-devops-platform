#!/usr/bin/env python3
"""
Lambda Function Tester - Day 29
Test all automation Lambda functions
"""

import boto3
import json

lambda_client = boto3.client(
    'lambda',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

def test_lambda(function_name, test_event):
    """Invoke Lambda function with test event"""
    print(f"\nTesting: {function_name}")
    print("-" * 70)
    
    try:
        response = lambda_client.invoke(
            FunctionName=function_name,
            InvocationType='RequestResponse',
            Payload=json.dumps(test_event)
        )
        
        result = json.loads(response['Payload'].read())
        print(f"Status Code: {result.get('statusCode')}")
        print(f"Response: {result.get('body')}")
        
        return True
    except Exception as e:
        print(f"Error: {e}")
        return False

def run_tests():
    """Run tests for all Lambda functions"""
    print("="*70)
    print("Lambda Automation Function Tests - Day 29")
    print("="*70)
    
    tests = [
        ('myapp-auto-stop-resources', {}),
        ('myapp-auto-tag', {
            'detail': {
                'eventName': 'RunInstances',
                'responseElements': {
                    'instancesSet': {
                        'items': [{'instanceId': 'i-test123'}]
                    }
                },
                'userIdentity': {'principalId': 'test-user'}
            }
        }),
        ('myapp-backup-verify', {}),
        ('myapp-security-remediation', {
            'detail': {
                'type': 'UnauthorizedAccess:EC2/SSHBruteForce',
                'resource': {
                    'instanceDetails': {'instanceId': 'i-test123'}
                }
            }
        }),
        ('myapp-health-check', {})
    ]
    
    results = []
    for function_name, event in tests:
        success = test_lambda(function_name, event)
        results.append((function_name, success))
    
    print("\n" + "="*70)
    print("Test Results Summary")
    print("="*70)
    
    passed = sum(1 for _, success in results if success)
    total = len(results)
    
    for function_name, success in results:
        status = "PASS" if success else "FAIL"
        print(f"  [{status}] {function_name}")
    
    print(f"\nTotal: {passed}/{total} tests passed")
    print("="*70)

if __name__ == '__main__':
    run_tests()
