#!/usr/bin/env python3
"""
EventBridge Event Publisher - Day 20
Test event automation by publishing custom events
"""

import boto3
import json
import time
from datetime import datetime, timezone

events_client = boto3.client(
    'events',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

def publish_event(source, detail_type, detail, event_bus='myapp-event-bus'):
    """Publish a single event to EventBridge"""
    try:
        response = events_client.put_events(
            Entries=[{
                'Time': datetime.now(timezone.utc),
                'Source': source,
                'DetailType': detail_type,
                'Detail': json.dumps(detail),
                'EventBusName': event_bus
            }]
        )
        failed = response.get('FailedEntryCount', 0)
        if failed == 0:
            print(f"✓ Published: [{source}] {detail_type}")
            return True
        else:
            print(f"✗ Failed: [{source}] {detail_type}")
            return False
    except Exception as e:
        print(f"✗ Error: {e}")
        return False

if __name__ == '__main__':
    print("="*60)
    print("EventBridge Event Publisher - Day 20")
    print("="*60)
    print()

    # Test 1: Publish application error event
    print("Test 1: Publishing critical application error...")
    publish_event(
        source='myapp.backend',
        detail_type='ApplicationError',
        detail={
            'errorType': 'DatabaseConnectionError',
            'severity': 'CRITICAL',
            'service': 'user-service',
            'message': 'Failed to connect to primary database',
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'retryCount': 3
        }
    )
    time.sleep(1)

    # Test 2: Publish high severity error
    print("\nTest 2: Publishing high severity error...")
    publish_event(
        source='myapp.backend',
        detail_type='ApplicationError',
        detail={
            'errorType': 'MemoryOverflowError',
            'severity': 'HIGH',
            'service': 'payment-service',
            'message': 'Memory usage exceeded threshold',
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'memoryUsage': '95%'
        }
    )
    time.sleep(1)

    # Test 3: Publish successful deployment
    print("\nTest 3: Publishing successful deployment...")
    publish_event(
        source='myapp.cicd',
        detail_type='DeploymentCompleted',
        detail={
            'version': 'v2.1.0',
            'environment': 'dev',
            'service': 'api-gateway',
            'deployedBy': 'github-actions',
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'duration': '3m 45s'
        }
    )
    time.sleep(1)

    # Test 4: Publish failed deployment
    print("\nTest 4: Publishing failed deployment...")
    publish_event(
        source='myapp.cicd',
        detail_type='DeploymentFailed',
        detail={
            'version': 'v2.1.1',
            'environment': 'dev',
            'service': 'auth-service',
            'deployedBy': 'github-actions',
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'failureReason': 'Health check failed after 3 attempts'
        }
    )
    time.sleep(1)

    # Test 5: Publish low severity event (should NOT trigger critical rule)
    print("\nTest 5: Publishing low severity error (no alert expected)...")
    publish_event(
        source='myapp.backend',
        detail_type='ApplicationError',
        detail={
            'errorType': 'ValidationError',
            'severity': 'LOW',
            'service': 'api-gateway',
            'message': 'Invalid input format',
            'timestamp': datetime.now(timezone.utc).isoformat()
        }
    )
    time.sleep(1)

    # Test 6: Publish to default event bus
    print("\nTest 6: Publishing to default event bus...")
    publish_event(
        source='myapp.monitoring',
        detail_type='MetricThresholdBreached',
        detail={
            'metric': 'CPUUtilization',
            'value': 92,
            'threshold': 80,
            'timestamp': datetime.now(timezone.utc).isoformat()
        },
        event_bus='default'
    )

    print()
    print("="*60)
    print("Event publishing complete!")
    print("="*60)
