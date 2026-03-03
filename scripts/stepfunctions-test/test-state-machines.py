"""
Step Functions Test Script - Day 33
Validates all state machines registered on LocalStack
"""

import boto3
import json

sfn = boto3.client(
    'stepfunctions',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

EXPECTED = [
    'EC2HealthCheckWorkflow',
    'AutoRemediationWorkflow',
    'DRBackupWorkflow'
]

def test_state_machine(name, arns):
    arn = arns.get(name)
    if not arn:
        print(f"  ERROR: {name} not found in registered machines")
        return False

    try:
        response = sfn.describe_state_machine(stateMachineArn=arn)
        definition = json.loads(response['definition'])

        print(f"  Name       : {response['name']}")
        print(f"  Status     : {response['status']}")
        print(f"  StartAt    : {definition.get('StartAt')}")
        print(f"  States     : {list(definition.get('States', {}).keys())}")
        return True
    except Exception as e:
        print(f"  ERROR: {e}")
        return False

def run_tests():
    print("=" * 55)
    print("Step Functions Validation - Day 33")
    print("=" * 55)

    # Get all registered ARNs
    response = sfn.list_state_machines()
    arns = {m['name']: m['stateMachineArn'] for m in response['stateMachines']}

    passed = 0
    failed = 0

    for name in EXPECTED:
        print(f"\nTesting: {name}")
        if test_state_machine(name, arns):
            print(f"  PASS")
            passed += 1
        else:
            print(f"  FAIL")
            failed += 1

    print("\n" + "=" * 55)
    print(f"Results: {passed} passed, {failed} failed")
    print("=" * 55)

if __name__ == '__main__':
    run_tests()
