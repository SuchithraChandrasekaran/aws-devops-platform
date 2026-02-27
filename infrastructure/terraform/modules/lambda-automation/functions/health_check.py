"""
Health Check Lambda - Day 29
Perform health checks on infrastructure components
"""

import boto3
import json
import requests

ec2 = boto3.client('ec2')
rds = boto3.client('rds')
s3 = boto3.client('s3')
sns = boto3.client('sns')

SNS_TOPIC_ARN = 'arn:aws:sns:us-east-1:000000000000:warning-alerts'

def lambda_handler(event, context):
    """Perform comprehensive health checks"""
    print(f"Event: {json.dumps(event)}")
    
    results = {
        'ec2': check_ec2_health(),
        'rds': check_rds_health(),
        's3': check_s3_health(),
        'endpoints': check_endpoint_health()
    }
    
    unhealthy = []
    for service, status in results.items():
        if not status['healthy']:
            unhealthy.append(f"{service}: {status['message']}")
    
    if unhealthy:
        send_health_alert(unhealthy)
        return {
            'statusCode': 500,
            'body': json.dumps({
                'status': 'UNHEALTHY',
                'issues': unhealthy,
                'details': results
            })
        }
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'status': 'HEALTHY',
            'details': results
        })
    }

def check_ec2_health():
    """Check EC2 instance health"""
    try:
        response = ec2.describe_instance_status()
        
        unhealthy = []
        for status in response['InstanceStatuses']:
            instance_id = status['InstanceId']
            system_status = status['SystemStatus']['Status']
            instance_status = status['InstanceStatus']['Status']
            
            if system_status != 'ok' or instance_status != 'ok':
                unhealthy.append(instance_id)
        
        if unhealthy:
            return {
                'healthy': False,
                'message': f'{len(unhealthy)} unhealthy instances'
            }
        
        return {'healthy': True, 'message': 'All instances healthy'}
        
    except Exception as e:
        return {'healthy': False, 'message': str(e)}

def check_rds_health():
    """Check RDS database health"""
    try:
        response = rds.describe_db_instances()
        
        unhealthy = []
        for db in response['DBInstances']:
            db_id = db['DBInstanceIdentifier']
            status = db['DBInstanceStatus']
            
            if status not in ['available', 'storage-optimization']:
                unhealthy.append(f"{db_id}: {status}")
        
        if unhealthy:
            return {
                'healthy': False,
                'message': f'{len(unhealthy)} unhealthy databases'
            }
        
        return {'healthy': True, 'message': 'All databases healthy'}
        
    except Exception as e:
        return {'healthy': False, 'message': str(e)}

def check_s3_health():
    """Check S3 bucket accessibility"""
    try:
        response = s3.list_buckets()
        
        inaccessible = []
        for bucket in response['Buckets'][:5]:
            bucket_name = bucket['Name']
            
            try:
                s3.head_bucket(Bucket=bucket_name)
            except:
                inaccessible.append(bucket_name)
        
        if inaccessible:
            return {
                'healthy': False,
                'message': f'{len(inaccessible)} inaccessible buckets'
            }
        
        return {'healthy': True, 'message': 'All buckets accessible'}
        
    except Exception as e:
        return {'healthy': False, 'message': str(e)}

def check_endpoint_health():
    """Check application endpoint health"""
    endpoints = [
        'http://localhost:8000/health',
        'http://localhost:9090/-/healthy'
    ]
    
    unhealthy = []
    for endpoint in endpoints:
        try:
            response = requests.get(endpoint, timeout=5)
            if response.status_code != 200:
                unhealthy.append(endpoint)
        except:
            unhealthy.append(endpoint)
    
    if unhealthy:
        return {
            'healthy': False,
            'message': f'{len(unhealthy)} endpoints down'
        }
    
    return {'healthy': True, 'message': 'All endpoints healthy'}

def send_health_alert(issues):
    """Send health alert via SNS"""
    try:
        message = "Health Check Alert\n\n"
        message += "Unhealthy components:\n"
        for issue in issues:
            message += f"- {issue}\n"
        
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject='Health Check Failed',
            Message=message
        )
        print("Health alert sent")
        
    except Exception as e:
        print(f"Error sending alert: {e}")
