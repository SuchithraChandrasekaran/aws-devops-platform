"""
Alarm Handler Lambda - Day 30
Handle CloudWatch alarm state changes
"""

import boto3
import json

sns = boto3.client('sns')
cloudwatch = boto3.client('cloudwatch')

SNS_TOPIC_ARN = 'arn:aws:sns:us-east-1:000000000000:critical-alerts'

def lambda_handler(event, context):
    """Handle alarm state changes"""
    print(f"Event: {json.dumps(event)}")
    
    alarm_name = event.get('alarm_name')
    new_state = event.get('new_state')
    reason = event.get('reason')
    
    if new_state == 'ALARM':
        handle_alarm_triggered(alarm_name, reason)
    elif new_state == 'OK':
        handle_alarm_recovered(alarm_name)
    
    return {
        'statusCode': 200,
        'body': json.dumps(f'Handled alarm {alarm_name}')
    }

def handle_alarm_triggered(alarm_name, reason):
    """Handle alarm triggered event"""
    try:
        # Get alarm details
        response = cloudwatch.describe_alarms(AlarmNames=[alarm_name])
        
        if response['MetricAlarms']:
            alarm = response['MetricAlarms'][0]
            metric_name = alarm.get('MetricName')
            
            message = f"ALARM TRIGGERED\n\n"
            message += f"Alarm: {alarm_name}\n"
            message += f"Metric: {metric_name}\n"
            message += f"Reason: {reason}\n\n"
            message += "Automated remediation may be in progress."
            
            send_notification('CloudWatch Alarm Triggered', message)
        
    except Exception as e:
        print(f"Error handling alarm: {e}")

def handle_alarm_recovered(alarm_name):
    """Handle alarm recovered event"""
    try:
        message = f"Alarm {alarm_name} has recovered to OK state"
        send_notification('CloudWatch Alarm Recovered', message)
        print(f"Alarm {alarm_name} recovered")
        
    except Exception as e:
        print(f"Error handling recovery: {e}")

def send_notification(subject, message):
    """Send SNS notification"""
    try:
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject=subject,
            Message=message
        )
    except Exception as e:
        print(f"Error sending notification: {e}")
