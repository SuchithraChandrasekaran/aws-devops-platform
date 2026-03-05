"""
Automation Integration Test - Day 35 Checkpoint
Tests: Step Functions, SQS, SNS subscriptions (Days 29-34)
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
print("Automation Layer - Days 29-34")
print("=" * 55)

# Step Functions (Day 33)
def check_stepfunctions():
    sfn = client('stepfunctions')
    machines = sfn.list_state_machines()
    assert len(machines['stateMachines']) >= 3, \
        f"Expected 3 state machines, found {len(machines['stateMachines'])}"

check("Step Functions state machines exist (Day 33)", check_stepfunctions)

# SQS queues (Day 34)
def check_sqs():
    sqs = client('sqs')
    queues = sqs.list_queues()
    urls = queues.get('QueueUrls', [])
    assert len(urls) >= 4, f"Expected 4 queues, found {len(urls)}"

check("SQS queues exist (Day 34)", check_sqs)

# SNS subscriptions (Day 34)
def check_subscriptions():
    sns = client('sns')
    subs = sns.list_subscriptions()
    assert len(subs['Subscriptions']) >= 3, \
        f"Expected 3 subscriptions, found {len(subs['Subscriptions'])}"

check("SNS subscriptions exist (Day 34)", check_subscriptions)

# DLQ exists
def check_dlq():
    sqs = client('sqs')
    queues = sqs.list_queues()
    urls = queues.get('QueueUrls', [])
    assert any('dead-letter' in u for u in urls), "Dead letter queue not found"

check("Dead Letter Queue exists (Day 34)", check_dlq)

print()
passed = sum(1 for _, r in results if r == 'PASS')
failed = sum(1 for _, r in results if r == 'FAIL')
print(f"Automation: {passed} passed, {failed} failed")
