"""
Enhanced Security Remediation Lambda - Day 29
Consolidated security remediation for multiple resource types
"""

import boto3
import json

ec2 = boto3.client('ec2')
iam = boto3.client('iam')
s3 = boto3.client('s3')

def lambda_handler(event, context):
    """Handle security remediation"""
    print(f"Event: {json.dumps(event)}")
    
    finding_type = event.get('detail', {}).get('type', '')
    
    if 'UnauthorizedAccess:EC2' in finding_type:
        remediate_security_group(event)
    elif 'Policy:IAMUser' in finding_type:
        remediate_iam_policy(event)
    elif 'S3' in finding_type:
        remediate_s3_bucket(event)
    else:
        print(f"No remediation for finding type: {finding_type}")
    
    return {
        'statusCode': 200,
        'body': json.dumps('Remediation complete')
    }

def remediate_security_group(event):
    """Remove overly permissive security group rules"""
    try:
        detail = event.get('detail', {})
        resource = detail.get('resource', {})
        instance_id = resource.get('instanceDetails', {}).get('instanceId')
        
        if not instance_id:
            return
        
        response = ec2.describe_instances(InstanceIds=[instance_id])
        
        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                for sg in instance['SecurityGroups']:
                    sg_id = sg['GroupId']
                    
                    sg_details = ec2.describe_security_groups(GroupIds=[sg_id])
                    
                    for permission in sg_details['SecurityGroups'][0]['IpPermissions']:
                        for ip_range in permission.get('IpRanges', []):
                            if ip_range.get('CidrIp') == '0.0.0.0/0':
                                from_port = permission.get('FromPort', 0)
                                
                                if from_port in [22, 3389]:
                                    ec2.revoke_security_group_ingress(
                                        GroupId=sg_id,
                                        IpPermissions=[permission]
                                    )
                                    print(f"Removed public access on port {from_port}")
        
    except Exception as e:
        print(f"Error remediating security group: {e}")

def remediate_iam_policy(event):
    """Detach overly permissive IAM policies"""
    try:
        detail = event.get('detail', {})
        resource = detail.get('resource', {})
        user_name = resource.get('accessKeyDetails', {}).get('userName')
        
        if not user_name:
            return
        
        response = iam.list_attached_user_policies(UserName=user_name)
        
        for policy in response['AttachedPolicies']:
            policy_arn = policy['PolicyArn']
            
            if 'AdministratorAccess' in policy_arn:
                iam.detach_user_policy(
                    UserName=user_name,
                    PolicyArn=policy_arn
                )
                print(f"Detached admin policy from {user_name}")
        
    except Exception as e:
        print(f"Error remediating IAM policy: {e}")

def remediate_s3_bucket(event):
    """Secure S3 bucket configuration"""
    try:
        detail = event.get('detail', {})
        resource = detail.get('resource', {})
        bucket_name = resource.get('s3BucketDetails', {}).get('name')
        
        if not bucket_name:
            return
        
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
        
    except Exception as e:
        print(f"Error remediating S3 bucket: {e}")
