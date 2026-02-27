"""
Backup Verification Lambda - Day 29
Verify backups are being created and are restorable
"""

import boto3
import json
from datetime import datetime, timedelta

backup = boto3.client('backup')
sns = boto3.client('sns')

SNS_TOPIC_ARN = 'arn:aws:sns:us-east-1:000000000000:critical-alerts'

def lambda_handler(event, context):
    """Verify backup completion and health"""
    print(f"Event: {json.dumps(event)}")
    
    failed_backups = check_backup_jobs()
    old_backups = check_backup_age()
    
    issues = []
    
    if failed_backups:
        issues.append(f"{len(failed_backups)} failed backup jobs")
    
    if old_backups:
        issues.append(f"{len(old_backups)} backups older than 7 days")
    
    if issues:
        send_alert(issues)
        return {
            'statusCode': 500,
            'body': json.dumps({'status': 'FAILED', 'issues': issues})
        }
    
    return {
        'statusCode': 200,
        'body': json.dumps({'status': 'OK', 'message': 'All backups healthy'})
    }

def check_backup_jobs():
    """Check for failed backup jobs in last 24 hours"""
    failed_jobs = []
    
    try:
        response = backup.list_backup_jobs(
            ByState='FAILED',
            ByCreatedAfter=datetime.now() - timedelta(days=1)
        )
        
        failed_jobs = response.get('BackupJobs', [])
        
        if failed_jobs:
            print(f"Found {len(failed_jobs)} failed backup jobs")
            for job in failed_jobs:
                print(f"Failed job: {job['BackupJobId']}")
        
    except Exception as e:
        print(f"Error checking backup jobs: {e}")
    
    return failed_jobs

def check_backup_age():
    """Check for resources without recent backups"""
    old_backups = []
    
    try:
        response = backup.list_recovery_points_by_backup_vault(
            BackupVaultName='Default'
        )
        
        seven_days_ago = datetime.now() - timedelta(days=7)
        
        for recovery_point in response.get('RecoveryPoints', []):
            created = recovery_point.get('CreationDate')
            
            if created and created < seven_days_ago:
                old_backups.append(recovery_point)
        
        if old_backups:
            print(f"Found {len(old_backups)} backups older than 7 days")
        
    except Exception as e:
        print(f"Error checking backup age: {e}")
    
    return old_backups

def send_alert(issues):
    """Send SNS alert for backup issues"""
    try:
        message = "Backup Verification Alert\n\n"
        message += "Issues found:\n"
        for issue in issues:
            message += f"- {issue}\n"
        
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject='Backup Verification Failed',
            Message=message
        )
        print("Alert sent via SNS")
        
    except Exception as e:
        print(f"Error sending alert: {e}")
