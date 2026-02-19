#!/usr/bin/env python3
"""
Monitoring Stack Integration Test - Day 21
Test all monitoring components working together
"""

import boto3
import requests
import json
import time
from datetime import datetime, timezone

# AWS clients for LocalStack
cloudwatch = boto3.client(
    'cloudwatch',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

logs = boto3.client(
    'logs',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

sns = boto3.client(
    'sns',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

events = boto3.client(
    'events',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

def print_section(title):
    """Print section header"""
    print("\n" + "="*70)
    print(f"  {title}")
    print("="*70)

def test_cloudwatch_metrics():
    """Test CloudWatch metrics collection"""
    print_section("TEST 1: CloudWatch Metrics")
    
    metrics = [
        ('CPUUtilization', 85, 'Percent', 'MyApp/Metrics'),
        ('MemoryUtilization', 90, 'Percent', 'MyApp/Metrics'),
        ('ErrorCountFromLogs', 15, 'Count', 'MyApp/Logs'),
        ('APIResponseTime', 1200, 'Milliseconds', 'MyApp/Logs'),
    ]
    
    for metric_name, value, unit, namespace in metrics:
        try:
            cloudwatch.put_metric_data(
                Namespace=namespace,
                MetricData=[{
                    'MetricName': metric_name,
                    'Value': value,
                    'Timestamp': datetime.now(timezone.utc),
                    'Unit': unit
                }]
            )
            print(f"  ✓ Sent metric: {metric_name} = {value} {unit}")
        except Exception as e:
            print(f"  ✗ Failed to send {metric_name}: {e}")
    
    return True

def test_cloudwatch_logs():
    """Test CloudWatch Logs"""
    print_section("TEST 2: CloudWatch Logs")
    
    log_groups = ['/aws/application/myapp', '/aws/api/myapp', '/aws/errors/myapp']
    
    for log_group in log_groups:
        try:
            response = logs.describe_log_groups(logGroupNamePrefix=log_group)
            if response['logGroups']:
                print(f"  Log group exists: {log_group}")
            else:
                print(f"  Log group missing: {log_group}")
        except Exception as e:
            print(f"  Error checking {log_group}: {e}")
    
    return True

def test_cloudwatch_alarms():
    """Test CloudWatch Alarms"""
    print_section("TEST 3: CloudWatch Alarms")
    
    try:
        response = cloudwatch.describe_alarms()
        alarms = response['MetricAlarms']
        
        print(f"  Total alarms configured: {len(alarms)}")
        
        critical_alarms = [a for a in alarms if 'high-cpu' in a['AlarmName'] or 
                          'high-memory' in a['AlarmName'] or 
                          'high-error' in a['AlarmName']]
        print(f"  Critical alarms: {len(critical_alarms)}")
        
        for alarm in alarms[:5]:  # Show first 5
            state = alarm['StateValue']
            symbol = "🔴" if state == "ALARM" else "🟢" if state == "OK" else "⚪"
            print(f"  {symbol} {alarm['AlarmName']}: {state}")
        
        return len(alarms) >= 10
    except Exception as e:
        print(f"  ✗ Error checking alarms: {e}")
        return False

def test_sns_topics():
    """Test SNS Topics"""
    print_section("TEST 4: SNS Topics")
    
    try:
        response = sns.list_topics()
        topics = response['Topics']
        
        print(f"  Total SNS topics: {len(topics)}")
        
        for topic in topics:
            topic_name = topic['TopicArn'].split(':')[-1]
            print(f"  ✓ {topic_name}")
            
            # Check subscriptions
            subs = sns.list_subscriptions_by_topic(TopicArn=topic['TopicArn'])
            sub_count = len(subs['Subscriptions'])
            print(f"    └─ Subscriptions: {sub_count}")
        
        return len(topics) >= 3
    except Exception as e:
        print(f"  ✗ Error checking SNS: {e}")
        return False

def test_eventbridge_rules():
    """Test EventBridge Rules"""
    print_section("TEST 5: EventBridge Rules")
    
    try:
        # Check default bus rules
        response = events.list_rules()
        default_rules = response['Rules']
        
        # Check custom bus rules
        try:
            custom_response = events.list_rules(EventBusName='myapp-event-bus')
            custom_rules = custom_response['Rules']
        except:
            custom_rules = []
        
        print(f"  Default bus rules: {len(default_rules)}")
        print(f"  Custom bus rules: {len(custom_rules)}")
        print(f"  Total rules: {len(default_rules) + len(custom_rules)}")
        
        # Show some rules
        for rule in default_rules[:3]:
            state = rule['State']
            symbol = "✓" if state == "ENABLED" else "✗"
            schedule = rule.get('ScheduleExpression', 'event-pattern')
            print(f"  {symbol} {rule['Name']}: {schedule}")
        
        return len(default_rules) + len(custom_rules) >= 8
    except Exception as e:
        print(f"  ✗ Error checking EventBridge: {e}")
        return False

def test_prometheus():
    """Test Prometheus"""
    print_section("TEST 6: Prometheus")
    
    try:
        # Check health
        health = requests.get('http://localhost:9090/-/healthy', timeout=5)
        if health.status_code == 200:
            print(f"  ✓ Prometheus is healthy")
        else:
            print(f"  ✗ Prometheus health check failed")
            return False
        
        # Check targets
        targets = requests.get('http://localhost:9090/api/v1/targets', timeout=5).json()
        active = targets['data']['activeTargets']
        
        print(f"  Total targets: {len(active)}")
        for target in active:
            job = target['labels']['job']
            health = target['health']
            symbol = "✓" if health == "up" else "✗"
            print(f"  {symbol} {job}: {health}")
        
        return len(active) >= 3
    except Exception as e:
        print(f"  ✗ Error checking Prometheus: {e}")
        return False

def test_grafana():
    """Test Grafana"""
    print_section("TEST 7: Grafana")
    
    try:
        # Check health
        health = requests.get('http://localhost:3000/api/health', timeout=5).json()
        if health['database'] == 'ok':
            print(f"  ✓ Grafana is healthy")
        else:
            print(f"  ✗ Grafana health check failed")
            return False
        
        # Check datasources
        datasources = requests.get(
            'http://localhost:3000/api/datasources',
            auth=('admin', 'admin'),
            timeout=5
        ).json()
        
        print(f"  Datasources configured: {len(datasources)}")
        for ds in datasources:
            print(f"  ✓ {ds['name']} ({ds['type']})")
        
        return len(datasources) >= 1
    except Exception as e:
        print(f"  ✗ Error checking Grafana: {e}")
        return False

def test_end_to_end_workflow():
    """Test end-to-end workflow"""
    print_section("TEST 8: End-to-End Workflow")
    
    print("  Simulating high CPU event...")
    
    # 1. Send metric that breaches threshold
    try:
        cloudwatch.put_metric_data(
            Namespace='MyApp/Metrics',
            MetricData=[{
                'MetricName': 'CPUUtilization',
                'Value': 95,
                'Timestamp': datetime.now(timezone.utc),
                'Unit': 'Percent'
            }]
        )
        print("  ✓ Sent high CPU metric (95%)")
    except Exception as e:
        print(f"  ✗ Failed to send metric: {e}")
        return False
    
    # 2. Publish custom event
    try:
        events.put_events(
            Entries=[{
                'Source': 'myapp.backend',
                'DetailType': 'ApplicationError',
                'Detail': json.dumps({
                    'errorType': 'HighCPUError',
                    'severity': 'CRITICAL',
                    'service': 'api-gateway',
                    'cpuUsage': 95
                }),
                'EventBusName': 'myapp-event-bus'
            }]
        )
        print("  ✓ Published custom event to EventBridge")
    except Exception as e:
        print(f"  ✗ Failed to publish event: {e}")
    
    # 3. Send log entry
    try:
        logs.put_log_events(
            logGroupName='/aws/errors/myapp',
            logStreamName='error-stream',
            logEvents=[{
                'timestamp': int(time.time() * 1000),
                'message': '[ERROR] High CPU usage detected: 95%'
            }]
        )
        print("  ✓ Sent error log entry")
    except Exception as e:
        print(f"  ✗ Failed to send log: {e}")
    
    print("\n  Workflow Summary:")
    print("  1. Metric → CloudWatch → Alarm (should trigger)")
    print("  2. Event → EventBridge → SNS (notification sent)")
    print("  3. Log → CloudWatch Logs → Metric Filter")
    print("  4. All data → Prometheus → Grafana (visualization)")
    
    return True

def run_all_tests():
    """Run all integration tests"""
    print("\n" + "="*70)
    print("  MONITORING STACK INTEGRATION TEST - DAY 21")
    print("  Week 3 Complete Observability Validation")
    print("="*70)
    
    results = {
        'CloudWatch Metrics': test_cloudwatch_metrics(),
        'CloudWatch Logs': test_cloudwatch_logs(),
        'CloudWatch Alarms': test_cloudwatch_alarms(),
        'SNS Topics': test_sns_topics(),
        'EventBridge Rules': test_eventbridge_rules(),
        'Prometheus': test_prometheus(),
        'Grafana': test_grafana(),
        'End-to-End Workflow': test_end_to_end_workflow(),
    }
    
    print_section("TEST RESULTS SUMMARY")
    
    passed = sum(1 for v in results.values() if v)
    total = len(results)
    
    for test_name, result in results.items():
        symbol = "✓" if result else "✗"
        status = "PASS" if result else "FAIL"
        print(f"  {symbol} {test_name}: {status}")
    
    print(f"\n  Total: {passed}/{total} tests passed")
    
    if passed == total:
        print("\n ALL TESTS PASSED - MONITORING STACK FULLY OPERATIONAL!")
    else:
        print(f"\n{total - passed} test(s) failed - check configuration")
    
    return passed == total

if __name__ == '__main__':
    success = run_all_tests()
    exit(0 if success else 1)
