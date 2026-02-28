"""
IAM Audit Handler Lambda - Day 30
Audit and respond to IAM policy changes
"""

import boto3
import json

iam = boto3.client('iam')
sns = boto3.client('sns')

SNS_TOPIC_ARN = 'arn:aws:sns:us-east-1:000000000000:critical-alerts'
ALLOWED_PRINCIPALS = ['terraform', 'admin']

def lambda_handler(event, context):
    """Handle IAM policy changes"""
    print(f"Event: {json.dumps(event)}")
    
    detail = event.get('detail', {})
    event_name = detail.get('eventName')
    principal = detail.get('userIdentity', {}).get('principalId', '').lower()
    
    # Check if change was made by authorized principal
    authorized = any(allowed in principal for allowed in ALLOWED_PRINCIPALS)
    
    if not authorized:
        handle_unauthorized_change(detail)
    else:
        audit_policy_change(detail)
    
    return {
        'statusCode': 200,
        'body': json.dumps('IAM change audited')
    }

def handle_unauthorized_change(detail):
    """Handle unauthorized IAM changes"""
    event_name = detail.get('eventName')
    principal = detail.get('userIdentity', {}).get('principalId')
    
    message = f"ALERT: Unauthorized IAM change\n"
    message += f"Event: {event_name}\n"
    message += f"Principal: {principal}\n"
    message += f"Time: {detail.get('eventTime')}"
    
    send_notification('Unauthorized IAM Change', message)
    print(f"Unauthorized change by {principal}")

def audit_policy_change(detail):
    """Audit authorized policy changes"""
    event_name = detail.get('eventName')
    
    if event_name in ['AttachUserPolicy', 'AttachRolePolicy']:
        check_dangerous_attachments(detail)

def check_dangerous_attachments(detail):
    """Check for dangerous policy attachments"""
    request_params = detail.get('requestParameters', {})
    policy_arn = request_params.get('policyArn', '')
    
    dangerous_policies = [
        'AdministratorAccess',
        'PowerUserAccess',
        'arn:aws:iam::aws:policy/AdministratorAccess'
    ]
    
    if any(dangerous in policy_arn for dangerous in dangerous_policies):
        user_name = request_params.get('userName') or request_params.get('roleName')
        
        message = f"WARNING: Powerful policy attached\n"
        message += f"Policy: {policy_arn}\n"
        message += f"Attached to: {user_name}"
        
        send_notification('Powerful Policy Attached', message)

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
