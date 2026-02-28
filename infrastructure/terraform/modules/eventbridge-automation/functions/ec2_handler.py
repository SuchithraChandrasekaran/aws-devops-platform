"""
EC2 Event Handler Lambda - Day 30
Handle EC2 instance state changes and events
"""

import boto3
import json

ec2 = boto3.client('ec2')
sns = boto3.client('sns')

SNS_TOPIC_ARN = 'arn:aws:sns:us-east-1:000000000000:warning-alerts'

def lambda_handler(event, context):
    """Handle EC2 events"""
    print(f"Event: {json.dumps(event)}")
    
    detail = event.get('detail', {})
    instance_id = detail.get('instance-id')
    state = detail.get('state')
    
    if state == 'stopped':
        handle_instance_stopped(instance_id)
    elif state == 'terminated':
        handle_instance_terminated(instance_id)
    elif state == 'running':
        handle_instance_running(instance_id)
    
    return {
        'statusCode': 200,
        'body': json.dumps(f'Handled {state} event for {instance_id}')
    }

def handle_instance_stopped(instance_id):
    """Handle instance stopped event"""
    try:
        # Check if instance should be restarted
        response = ec2.describe_instances(InstanceIds=[instance_id])
        
        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                tags = {tag['Key']: tag['Value'] for tag in instance.get('Tags', [])}
                
                if tags.get('AutoRestart') == 'true':
                    ec2.start_instances(InstanceIds=[instance_id])
                    print(f"Auto-restarted instance {instance_id}")
                    
                    send_notification(
                        f"Instance {instance_id} was stopped and auto-restarted"
                    )
        
    except Exception as e:
        print(f"Error handling stopped instance: {e}")

def handle_instance_terminated(instance_id):
    """Handle instance terminated event"""
    try:
        # Send notification about termination
        send_notification(
            f"WARNING: Instance {instance_id} was terminated"
        )
        print(f"Instance {instance_id} terminated")
        
    except Exception as e:
        print(f"Error handling terminated instance: {e}")

def handle_instance_running(instance_id):
    """Handle instance running event"""
    try:
        # Verify security configuration
        response = ec2.describe_instances(InstanceIds=[instance_id])
        
        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                # Check if instance is in public subnet
                subnet_id = instance.get('SubnetId')
                
                if subnet_id:
                    subnet = ec2.describe_subnets(SubnetIds=[subnet_id])
                    is_public = subnet['Subnets'][0].get('MapPublicIpOnLaunch', False)
                    
                    if is_public:
                        send_notification(
                            f"Instance {instance_id} launched in public subnet"
                        )
        
    except Exception as e:
        print(f"Error handling running instance: {e}")

def send_notification(message):
    """Send SNS notification"""
    try:
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject='EC2 Event Notification',
            Message=message
        )
    except Exception as e:
        print(f"Error sending notification: {e}")
