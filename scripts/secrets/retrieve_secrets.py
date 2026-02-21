#!/usr/bin/env python3
"""
Secret Retrieval Script - Day 23
Safely retrieve and use encrypted secrets
"""

import boto3
import json

secrets_client = boto3.client(
    'secretsmanager',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

ssm_client = boto3.client(
    'ssm',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

def get_secret(secret_name):
    """Retrieve secret from Secrets Manager"""
    try:
        response = secrets_client.get_secret_value(SecretId=secret_name)
        secret_string = response['SecretString']
        return json.loads(secret_string)
    except Exception as e:
        print(f"Error retrieving secret {secret_name}: {e}")
        return None

def get_ssm_parameter(parameter_name, decrypt=False):
    """Retrieve parameter from SSM Parameter Store"""
    try:
        response = ssm_client.get_parameter(
            Name=parameter_name,
            WithDecryption=decrypt
        )
        return response['Parameter']['Value']
    except Exception as e:
        print(f"Error retrieving parameter {parameter_name}: {e}")
        return None

if __name__ == '__main__':
    print("="*70)
    print("Secret Retrieval Test - Day 23")
    print("="*70)
    
    # Test 1: Retrieve database credentials
    print("\nTest 1: Database Credentials")
    print("-" * 70)
    db_creds = get_secret('myapp/database/credentials')
    if db_creds:
        print(f"Username: {db_creds.get('username')}")
        print(f"Password: {'*' * len(db_creds.get('password', ''))}")
        print(f"Host: {db_creds.get('host')}")
        print(f"Port: {db_creds.get('port')}")
        print(f"Database: {db_creds.get('database')}")
    
    # Test 2: Retrieve API keys
    print("\nTest 2: API Keys")
    print("-" * 70)
    api_keys = get_secret('myapp/api/keys')
    if api_keys:
        for key_name in api_keys.keys():
            print(f"{key_name}: {'*' * 20}")
    
    # Test 3: Retrieve app config
    print("\nTest 3: Application Config")
    print("-" * 70)
    app_config = get_secret('myapp/app/config')
    if app_config:
        for config_name in app_config.keys():
            print(f"{config_name}: {'*' * 15}")
    
    # Test 4: Retrieve SSM parameters
    print("\nTest 4: SSM Parameters")
    print("-" * 70)
    
    db_endpoint = get_ssm_parameter('/myapp/dev/database/endpoint')
    print(f"DB Endpoint: {db_endpoint}")
    
    db_name = get_ssm_parameter('/myapp/dev/database/name')
    print(f"DB Name: {db_name}")
    
    db_password = get_ssm_parameter('/myapp/dev/database/password', decrypt=True)
    print(f"DB Password: {'*' * len(db_password) if db_password else 'None'}")
    
    api_url = get_ssm_parameter('/myapp/dev/api/base_url')
    print(f"API URL: {api_url}")
    
    features = get_ssm_parameter('/myapp/dev/features/enabled')
    print(f"Features: {features}")
    
    print("\n" + "="*70)
    print("Secret retrieval test complete")
    print("="*70)
