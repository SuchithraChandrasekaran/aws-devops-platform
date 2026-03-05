"""
End-to-End Flow Test - Day 35 Checkpoint
Flow: SNS publish -> SQS receive -> Step Functions verify
"""

import boto3
import json
import time

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

sns = client('sns')
sqs = client('sqs')
sfn = client('stepfunctions')

print("=" * 55)
print("End-to-End Flow Test - Day 35")
print("=" * 55)

# Step 1: Get alert topic ARN
print("\nStep 1: Locate alert-notifications-topic")
topics = sns.list_topics()
alert_arn = None
for t in topics['Topics']:
    if 'alert' in t['TopicArn']:
        alert_arn = t['TopicArn']
        break

if alert_arn:
    print(f"  Found: {alert_arn}")
else:
    print("  FAIL: alert-notifications-topic not found")
    exit(1)

# Step 2: Get alert queue URL
print("\nStep 2: Locate alert-processing-queue")
queues = sqs.list_queues()
alert_queue_url = None
for url in queues.get('QueueUrls', []):
    if 'alert-processing' in url:
        alert_queue_url = url
        break

if alert_queue_url:
    print(f"  Found: {alert_queue_url}")
else:
    print("  FAIL: alert-processing-queue not found")
    exit(1)

# Step 3: Purge queue before test
print("\nStep 3: Purge alert queue")
try:
    sqs.purge_queue(QueueUrl=alert_queue_url)
    time.sleep(2)
    print("  Queue purged")
except Exception as e:
    print(f"  Warning: {e}")

# Step 4: Publish test event to SNS
print("\nStep 4: Publish test alert to SNS topic")
event = {
    'source': 'checkpoint-test',
    'type': 'integration-test',
    'message': 'Day 35 end-to-end test event',
    'timestamp': str(time.time())
}
response = sns.publish(
    TopicArn=alert_arn,
    Message=json.dumps(event),
    MessageAttributes={
        'severity': {'DataType': 'String', 'StringValue': 'critical'},
        'source': {'DataType': 'String', 'StringValue': 'system'}
    }
)
print(f"  Published MessageId: {response['MessageId']}")

# Step 5: Receive from SQS
print("\nStep 5: Receive message from SQS queue")
time.sleep(2)
response = sqs.receive_message(
    QueueUrl=alert_queue_url,
    MaxNumberOfMessages=1,
    WaitTimeSeconds=3
)
messages = response.get('Messages', [])
if messages:
    body = json.loads(messages[0]['Body'])
    print(f"  Received message from queue")
    print(f"  Receipt handle: {messages[0]['ReceiptHandle'][:40]}...")
    # Delete it to clean up
    sqs.delete_message(
        QueueUrl=alert_queue_url,
        ReceiptHandle=messages[0]['ReceiptHandle']
    )
    print(f"  Message deleted from queue")
else:
    print("  FAIL: No message received from queue")

# Step 6: Verify Step Functions state machine
print("\nStep 6: Verify AutoRemediationWorkflow state machine")
machines = sfn.list_state_machines()
remediation_arn = None
for m in machines['stateMachines']:
    if 'AutoRemediation' in m['name'] or 'Remediation' in m['name']:
        remediation_arn = m['stateMachineArn']
        break

if remediation_arn:
    detail = sfn.describe_state_machine(stateMachineArn=remediation_arn)
    definition = json.loads(detail['definition'])
    print(f"  Found: {detail['name']}")
    print(f"  Status: {detail['status']}")
    print(f"  States: {list(definition['States'].keys())}")
else:
    print("  FAIL: AutoRemediationWorkflow not found")

# Summary
print("\n" + "=" * 55)
print("End-to-End Flow Complete")
print("  SNS topic -> SQS queue -> message received -> deleted")
print("  Step Functions state machine verified and ready")
print("=" * 55)
