"""
Auto-Stop Resources Lambda - Day 29
Automatically stop EC2 instances and RDS databases during off-hours
"""

import boto3
import json
from datetime import datetime

ec2 = boto3.client('ec2')
rds = boto3.client('rds')

def lambda_handler(event, context):
    """Stop resources based on schedule"""
    print(f"Event: {json.dumps(event)}")
    
    current_hour = datetime.now().hour
    
    # Stop resources after 6 PM or before 8 AM
    if current_hour >= 18 or current_hour < 8:
        stop_ec2_instances()
        stop_rds_databases()
        return {
            'statusCode': 200,
            'body': json.dumps('Resources stopped for off-hours')
        }
    
    return {
        'statusCode': 200,
        'body': json.dumps('Within business hours - no action taken')
    }

def stop_ec2_instances():
    """Stop EC2 instances tagged for auto-stop"""
    try:
        # Find instances tagged with AutoStop=true
        response = ec2.describe_instances(
            Filters=[
                {'Name': 'tag:AutoStop', 'Values': ['true']},
                {'Name': 'instance-state-name', 'Values': ['running']}
            ]
        )
        
        instance_ids = []
        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                instance_ids.append(instance['InstanceId'])
        
        if instance_ids:
            ec2.stop_instances(InstanceIds=instance_ids)
            print(f"Stopped instances: {instance_ids}")
        else:
            print("No instances to stop")
            
    except Exception as e:
        print(f"Error stopping EC2 instances: {e}")

def stop_rds_databases():
    """Stop RDS databases tagged for auto-stop"""
    try:
        # Find RDS instances tagged with AutoStop=true
        response = rds.describe_db_instances()
        
        for db in response['DBInstances']:
            db_id = db['DBInstanceIdentifier']
            
            # Check tags
            tags = rds.list_tags_for_resource(
                ResourceName=db['DBInstanceArn']
            )
            
            auto_stop = any(
                tag['Key'] == 'AutoStop' and tag['Value'] == 'true'
                for tag in tags['TagList']
            )
            
            if auto_stop and db['DBInstanceStatus'] == 'available':
                rds.stop_db_instance(DBInstanceIdentifier=db_id)
                print(f"Stopped RDS instance: {db_id}")
                
    except Exception as e:
        print(f"Error stopping RDS databases: {e}")
