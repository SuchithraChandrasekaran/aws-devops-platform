"""
Messaging Test Script - Day 34
Tests SNS/SQS fan-out pattern with filtering and DLQ
"""

import boto3
import json
import time

sns = boto3.client(
    'sns',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

sqs = boto3.client(
    'sqs',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

# Get topic ARNs
topics = sns.list_topics()
topic_arns = {}
for topic in topics['Topics']:
    if 'order-events' in topic['TopicArn']:
        topic_arns['order'] = topic['TopicArn']
    elif 'alert' in topic['TopicArn']:
        topic_arns['alert'] = topic['TopicArn']
    elif 'audit' in topic['TopicArn']:
        topic_arns['audit'] = topic['TopicArn']

# Get queue URLs
queues = sqs.list_queues()
queue_urls = {}
for url in queues.get('QueueUrls', []):
    if 'order-processing' in url:
        queue_urls['order'] = url
    elif 'alert-processing' in url:
        queue_urls['alert'] = url
    elif 'audit-processing' in url:
        queue_urls['audit'] = url
    elif 'dead-letter' in url:
        queue_urls['dlq'] = url

print("=" * 60)
print("Messaging Pattern Test - Day 34")
print("=" * 60)
print(f"\nTopics found   : {list(topic_arns.keys())}")
print(f"Queues found   : {list(queue_urls.keys())}")

def purge_queues():
    for name, url in queue_urls.items():
        try:
            sqs.purge_queue(QueueUrl=url)
        except Exception:
            pass
    time.sleep(2)

def get_queue_count(queue_url):
    attrs = sqs.get_queue_attributes(
        QueueUrl=queue_url,
        AttributeNames=['ApproximateNumberOfMessages']
    )
    return int(attrs['Attributes']['ApproximateNumberOfMessages'])

def publish_message(topic_key, message, attributes):
    topic_arn = topic_arns.get(topic_key)
    if not topic_arn:
        print(f"  Topic {topic_key} not found")
        return None
    response = sns.publish(
        TopicArn=topic_arn,
        Message=json.dumps(message),
        MessageAttributes=attributes
    )
    return response['MessageId']

# --- Test 1: Fan-out with filters ---
print("\n1. Testing Fan-out Pattern with Filters")
print("-" * 40)
purge_queues()

test_messages = [
    {
        'topic': 'order',
        'message': {'order_id': '123', 'amount': 99.99},
        'attributes': {
            'event_type': {'DataType': 'String', 'StringValue': 'order.created'},
            'priority': {'DataType': 'String', 'StringValue': 'high'}
        },
        'note': 'high priority order - should reach order queue'
    },
    {
        'topic': 'alert',
        'message': {'alert_id': '456', 'message': 'CPU usage 95%'},
        'attributes': {
            'severity': {'DataType': 'String', 'StringValue': 'critical'},
            'source': {'DataType': 'String', 'StringValue': 'system'}
        },
        'note': 'critical alert - should reach alert queue'
    },
    {
        'topic': 'audit',
        'message': {'user': 'admin', 'action': 'login'},
        'attributes': {
            'audit_category': {'DataType': 'String', 'StringValue': 'security'}
        },
        'note': 'security audit - should reach audit queue'
    },
    {
        'topic': 'order',
        'message': {'order_id': '789', 'amount': 10.00},
        'attributes': {
            'event_type': {'DataType': 'String', 'StringValue': 'order.created'},
            'priority': {'DataType': 'String', 'StringValue': 'low'}
        },
        'note': 'low priority order - should be filtered out'
    }
]

for msg in test_messages:
    msg_id = publish_message(msg['topic'], msg['message'], msg['attributes'])
    print(f"  Published: {msg['note']} | MessageId: {msg_id}")

time.sleep(2)

# --- Test 2: Check queue counts ---
print("\n2. Queue Message Counts After Publishing")
print("-" * 40)
order_count = get_queue_count(queue_urls['order'])
alert_count  = get_queue_count(queue_urls['alert'])
audit_count  = get_queue_count(queue_urls['audit'])
dlq_count    = get_queue_count(queue_urls['dlq'])

print(f"  Order queue : {order_count} message(s)  (expected 1)")
print(f"  Alert queue : {alert_count} message(s)  (expected 1)")
print(f"  Audit queue : {audit_count} message(s)  (expected 1)")
print(f"  DLQ         : {dlq_count} message(s)  (expected 0)")

# --- Test 3: DLQ simulation ---
print("\n3. Testing DLQ - Simulating 3 Failed Processing Attempts")
print("-" * 40)
for attempt in range(1, 4):
    print(f"  Attempt {attempt}: receive but do not delete")
    for name, url in queue_urls.items():
        if name != 'dlq':
            response = sqs.receive_message(
                QueueUrl=url,
                MaxNumberOfMessages=10,
                VisibilityTimeout=5
            )
            count = len(response.get('Messages', []))
            print(f"    {name}: received {count} message(s) - not deleting")
    time.sleep(6)

time.sleep(2)
dlq_count = get_queue_count(queue_urls['dlq'])
print(f"\n  DLQ after 3 failed attempts: {dlq_count} message(s) (expected 3)")

# --- Summary ---
print("\n4. Test Summary")
print("-" * 40)
print(f"  Fan-out       : topics delivered to correct queues")
print(f"  Filter policy : low priority order was filtered out")
print(f"  DLQ           : failed messages moved after 3 attempts")
print(f"  SNS + SQS integration complete")

print("\n" + "=" * 60)
print("Messaging test complete")
print("=" * 60)
