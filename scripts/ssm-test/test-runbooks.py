"""
SSM Runbook Test Script - Day 32
Validates all custom automation documents on LocalStack
"""

import boto3
import json

# LocalStack client
ssm = boto3.client(
    'ssm',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

RUNBOOKS = [
    'CustomEC2HealthCheck',
    'CustomStopIdleInstances',
    'CustomSecurityPatch',
    'CustomBackupAndVerify'
]

def test_document_exists(name):
    try:
        response = ssm.describe_document(Name=name)
        doc = response['Document']
        print(f"  Name        : {doc['Name']}")
        print(f"  Status      : {doc['Status']}")
        print(f"  DocType     : {doc['DocumentType']}")
        print(f"  SchemaVer   : {doc['SchemaVersion']}")
        return True
    except ssm.exceptions.InvalidDocument:
        print(f"  ERROR: Document {name} not found")
        return False
    except Exception as e:
        print(f"  ERROR: {e}")
        return False

def run_tests():
    print("=" * 50)
    print("SSM Runbook Validation - Day 32")
    print("=" * 50)

    passed = 0
    failed = 0

    for name in RUNBOOKS:
        print(f"\nTesting: {name}")
        if test_document_exists(name):
            print(f"  PASS")
            passed += 1
        else:
            print(f"  FAIL")
            failed += 1

    print("\n" + "=" * 50)
    print(f"Results: {passed} passed, {failed} failed")
    print("=" * 50)

if __name__ == '__main__':
    run_tests()
