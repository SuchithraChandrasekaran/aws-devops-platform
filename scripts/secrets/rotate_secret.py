#!/usr/bin/env python3
"""
Secret Rotation Script - Day 23
Demonstrate secret rotation capabilities
"""

import boto3
import json
import secrets
import string

secrets_client = boto3.client(
    'secretsmanager',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

def generate_password(length=20):
    """Generate a secure random password"""
    alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
    return ''.join(secrets.choice(alphabet) for _ in range(length))

def rotate_secret(secret_name, new_values):
    """Rotate a secret with new values"""
    try:
        secrets_client.put_secret_value(
            SecretId=secret_name,
            SecretString=json.dumps(new_values)
        )
        print(f"Secret {secret_name} rotated successfully")
        return True
    except Exception as e:
        print(f"Error rotating secret: {e}")
        return False

if __name__ == '__main__':
    print("="*70)
    print("Secret Rotation - Day 23")
    print("="*70)
    
    # Rotate database password
    print("\nRotating database credentials...")
    new_db_creds = {
        'username': 'dbadmin',
        'password': generate_password(),
        'host': 'localhost',
        'port': 5432,
        'database': 'myapp'
    }
    
    if rotate_secret('myapp/database/credentials', new_db_creds):
        print("Database password rotated")
        print(f"New password: {'*' * 20}")
    
    # Rotate JWT secret
    print("\nRotating application config...")
    new_app_config = {
        'jwt_secret': generate_password(32),
        'encryption_key': generate_password(32),
        'session_secret': generate_password(32)
    }
    
    if rotate_secret('myapp/app/config', new_app_config):
        print("Application secrets rotated")
    
    print("\n" + "="*70)
    print("Secret rotation complete")
    print("="*70)
