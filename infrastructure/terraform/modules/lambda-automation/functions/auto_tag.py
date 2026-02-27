"""
Auto-Tagging Lambda - Day 29
Automatically tag new resources with standard tags
"""

import boto3
import json
from datetime import datetime

ec2 = boto3.client('ec2')
s3 = boto3.client('s3')

STANDARD_TAGS = {
    'ManagedBy': 'Terraform',
    'Project': 'MyApp',
    'CostCenter': 'Engineering',
    'AutoTagged': 'true'
}

def lambda_handler(event, context):
    """Tag resources based on CloudTrail event"""
    print(f"Event: {json.dumps(event)}")
    
    detail = event.get('detail', {})
    event_name = detail.get('eventName')
    
    if event_name == 'RunInstances':
        tag_ec2_instances(detail)
    elif event_name == 'CreateBucket':
        tag_s3_bucket(detail)
    
    return {
        'statusCode': 200,
        'body': json.dumps('Auto-tagging complete')
    }

def tag_ec2_instances(detail):
    """Tag newly created EC2 instances"""
    try:
        response_elements = detail.get('responseElements', {})
        instances_set = response_elements.get('instancesSet', {})
        items = instances_set.get('items', [])
        
        for item in items:
            instance_id = item.get('instanceId')
            
            if instance_id:
                tags = [
                    {'Key': k, 'Value': v}
                    for k, v in STANDARD_TAGS.items()
                ]
                
                # Add creator tag
                user = detail.get('userIdentity', {}).get('principalId', 'unknown')
                tags.append({'Key': 'Creator', 'Value': user})
                
                # Add creation date
                tags.append({
                    'Key': 'CreatedDate',
                    'Value': datetime.now().strftime('%Y-%m-%d')
                })
                
                ec2.create_tags(Resources=[instance_id], Tags=tags)
                print(f"Tagged instance {instance_id}")
                
    except Exception as e:
        print(f"Error tagging EC2 instance: {e}")

def tag_s3_bucket(detail):
    """Tag newly created S3 buckets"""
    try:
        request_params = detail.get('requestParameters', {})
        bucket_name = request_params.get('bucketName')
        
        if bucket_name:
            tags = [
                {'Key': k, 'Value': v}
                for k, v in STANDARD_TAGS.items()
            ]
            
            # Add creator tag
            user = detail.get('userIdentity', {}).get('principalId', 'unknown')
            tags.append({'Key': 'Creator', 'Value': user})
            
            s3.put_bucket_tagging(
                Bucket=bucket_name,
                Tagging={'TagSet': tags}
            )
            print(f"Tagged bucket {bucket_name}")
            
    except Exception as e:
        print(f"Error tagging S3 bucket: {e}")
