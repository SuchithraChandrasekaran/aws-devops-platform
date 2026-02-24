"""
S3 Bucket Auto-Remediation Lambda
Automatically fixes insecure S3 bucket configurations
"""

import json
import boto3

s3 = boto3.client('s3')

def lambda_handler(event, context):
    """
    Remediate S3 bucket issues
    """
    print(f"Event: {json.dumps(event)}")
    
    finding = event.get('detail', {})
    finding_type = finding.get('type', '')
    
    if 'S3' in finding_type:
        remediate_s3_bucket(finding)
    else:
        print(f"No remediation for finding type: {finding_type}")
    
    return {
        'statusCode': 200,
        'body': json.dumps('S3 remediation completed')
    }

def remediate_s3_bucket(finding):
    """Remediate S3 bucket security issues"""
    try:
        resource = finding.get('resource', {})
        bucket_name = resource.get('s3BucketDetails', {}).get('name')
        
        if not bucket_name:
            print("No bucket name found")
            return
        
        # Enable encryption
        enable_bucket_encryption(bucket_name)
        
        # Block public access
        block_public_access(bucket_name)
        
        # Enable versioning
        enable_versioning(bucket_name)
        
        # Enable logging
        enable_logging(bucket_name)
        
        print(f"Remediated bucket: {bucket_name}")
        
    except Exception as e:
        print(f"Error remediating S3 bucket: {e}")

def enable_bucket_encryption(bucket_name):
    """Enable default encryption on bucket"""
    try:
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
    except Exception as e:
        print(f"Error enabling encryption: {e}")

def block_public_access(bucket_name):
    """Block all public access to bucket"""
    try:
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
    except Exception as e:
        print(f"Error blocking public access: {e}")

def enable_versioning(bucket_name):
    """Enable versioning on bucket"""
    try:
        s3.put_bucket_versioning(
            Bucket=bucket_name,
            VersioningConfiguration={
                'Status': 'Enabled'
            }
        )
        print(f"Enabled versioning for {bucket_name}")
    except Exception as e:
        print(f"Error enabling versioning: {e}")

def enable_logging(bucket_name):
    """Enable access logging on bucket"""
    try:
        # Note: In production, specify a logging bucket
        s3.put_bucket_logging(
            Bucket=bucket_name,
            BucketLoggingStatus={
                'LoggingEnabled': {
                    'TargetBucket': bucket_name,
                    'TargetPrefix': 'logs/'
                }
            }
        )
        print(f"Enabled logging for {bucket_name}")
    except Exception as e:
        print(f"Error enabling logging: {e}")
