"""
S3 Security Handler Lambda - Day 30
Secure newly created S3 buckets automatically
"""

import boto3
import json

s3 = boto3.client('s3')
sns = boto3.client('sns')

SNS_TOPIC_ARN = 'arn:aws:sns:us-east-1:000000000000:critical-alerts'

def lambda_handler(event, context):
    """Handle S3 security events"""
    print(f"Event: {json.dumps(event)}")
    
    detail = event.get('detail', {})
    event_name = detail.get('eventName')
    
    if event_name == 'CreateBucket':
        bucket_name = detail.get('requestParameters', {}).get('bucketName')
        secure_new_bucket(bucket_name)
    elif event_name in ['PutBucketAcl', 'PutBucketPolicy', 'DeletePublicAccessBlock']:
        bucket_name = detail.get('requestParameters', {}).get('bucketName')
        remediate_public_access(bucket_name)
    
    return {
        'statusCode': 200,
        'body': json.dumps('S3 security handled')
    }

def secure_new_bucket(bucket_name):
    """Apply security controls to new bucket"""
    if not bucket_name:
        return
    
    try:
        # Block public access
        s3.put_public_access_block(
            Bucket=bucket_name,
            PublicAccessBlockConfiguration={
                'BlockPublicAcls': True,
                'IgnorePublicAcls': True,
                'BlockPublicPolicy': True,
                'RestrictPublicBuckets': True
            }
        )
        print(f"Blocked public access for {bucket_name}")
        
        # Enable encryption
        s3.put_bucket_encryption(
            Bucket=bucket_name,
            ServerSideEncryptionConfiguration={
                'Rules': [{
                    'ApplyServerSideEncryptionByDefault': {
                        'SSEAlgorithm': 'AES256'
                    }
                }]
            }
        )
        print(f"Enabled encryption for {bucket_name}")
        
        # Enable versioning
        s3.put_bucket_versioning(
            Bucket=bucket_name,
            VersioningConfiguration={
                'Status': 'Enabled'
            }
        )
        print(f"Enabled versioning for {bucket_name}")
        
        send_notification(
            f"New bucket {bucket_name} secured with encryption and public access block"
        )
        
    except Exception as e:
        print(f"Error securing bucket: {e}")

def remediate_public_access(bucket_name):
    """Remediate public access configuration changes"""
    if not bucket_name:
        return
    
    try:
        # Re-apply public access block
        s3.put_public_access_block(
            Bucket=bucket_name,
            PublicAccessBlockConfiguration={
                'BlockPublicAcls': True,
                'IgnorePublicAcls': True,
                'BlockPublicPolicy': True,
                'RestrictPublicBuckets': True
            }
        )
        
        send_notification(
            f"ALERT: Public access configuration changed on {bucket_name} - remediated"
        )
        
    except Exception as e:
        print(f"Error remediating public access: {e}")

def send_notification(message):
    """Send SNS notification"""
    try:
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject='S3 Security Event',
            Message=message
        )
    except Exception as e:
        print(f"Error sending notification: {e}")
