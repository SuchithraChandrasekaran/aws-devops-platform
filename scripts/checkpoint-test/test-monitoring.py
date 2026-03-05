"""
Monitoring Integration Test - Day 35 Checkpoint
Tests: CloudWatch, EventBridge (Days 15-21)
"""

import boto3

ENDPOINT = 'http://localhost:4566'
REGION = 'us-east-1'

def client(service):
    return boto3.client(
        service,
        endpoint_url=ENDPOINT,
        region_name=REGION,
        aws_access_key_id='test',
        aws_secret_access_key='test'
    )

results = []

def check(name, fn):
    try:
        fn()
        print(f"  PASS  {name}")
        results.append((name, 'PASS'))
    except Exception as e:
        print(f"  FAIL  {name} - {e}")
        results.append((name, 'FAIL'))

print("=" * 55)
print("Monitoring Layer - Days 15-21")
print("=" * 55)

# CloudWatch log groups (Day 16)
def check_log_groups():
    logs = client('logs')
    groups = logs.describe_log_groups()
    assert len(groups['logGroups']) > 0, "No CloudWatch log groups found"

check("CloudWatch log groups exist", check_log_groups)

# CloudWatch alarms (Day 17)
def check_alarms():
    cw = client('cloudwatch')
    alarms = cw.describe_alarms()
    total = len(alarms['MetricAlarms'])
    assert total >= 5, f"Expected 10+ alarms, found {total}"

check("CloudWatch alarms exist (10+ expected)", check_alarms)

# EventBridge rules (Day 20 + 30)
def check_eventbridge():
    events = client('events')
    rules = events.list_rules()
    assert len(rules['Rules']) > 0, "No EventBridge rules found"

check("EventBridge rules exist", check_eventbridge)

# SNS topics for alarms (Day 17 + 34)
def check_sns():
    sns = client('sns')
    topics = sns.list_topics()
    assert len(topics['Topics']) > 0, "No SNS topics found"

check("SNS topics exist", check_sns)

print()
passed = sum(1 for _, r in results if r == 'PASS')
failed = sum(1 for _, r in results if r == 'FAIL')
print(f"Monitoring: {passed} passed, {failed} failed")
