"""
Infrastructure Integration Test - Day 35 Checkpoint
Tests: VPC, S3, DynamoDB, SSM, CloudFormation (Days 1-14)
"""

import boto3
import json

ENDPOINT = 'http://localhost:4566'
REGION = 'us-east-1'

def client(service):
    return boto3.client(
        service,
        endpoint_url=ENDPOINT,
        region_name=REGION,
        aws_access_key_id='test',
        aws_secret_access_key='test'
    )

results = []

def check(name, fn):
    try:
        fn()
        print(f"  PASS  {name}")
        results.append((name, 'PASS'))
    except Exception as e:
        print(f"  FAIL  {name} - {e}")
        results.append((name, 'FAIL'))

print("=" * 55)
print("Infrastructure Layer - Days 1-14")
print("=" * 55)

# VPC (Day 1-2)
def check_vpc():
    ec2 = client('ec2')
    vpcs = ec2.describe_vpcs()
    assert len(vpcs['Vpcs']) > 0, "No VPCs found"

check("VPC exists on LocalStack", check_vpc)

# S3 state bucket (Day 12)
def check_s3():
    s3 = client('s3')
    buckets = s3.list_buckets()
    names = [b['Name'] for b in buckets['Buckets']]
    assert any('state' in n or 'terraform' in n for n in names), f"No state bucket found in {names}"

check("Terraform state S3 bucket exists", check_s3)

# DynamoDB lock table (Day 12)
def check_dynamodb():
    dynamodb = client('dynamodb')
    tables = dynamodb.list_tables()
    assert any('lock' in t or 'state' in t for t in tables['TableNames']), \
        f"No lock table found in {tables['TableNames']}"

check("DynamoDB state lock table exists", check_dynamodb)

# SSM Parameters (Day 13 + 23)
def check_ssm():
    ssm = client('ssm')
    params = ssm.describe_parameters()
    assert len(params['Parameters']) > 0, "No SSM parameters found"

check("SSM parameters exist", check_ssm)

# SSM Runbooks (Day 32)
def check_runbooks():
    ssm = client('ssm')
    docs = ssm.list_documents(Filters=[{'Key': 'Owner', 'Values': ['Self']}])
    names = [d['Name'] for d in docs['DocumentIdentifiers']]
    assert len(names) >= 4, f"Expected 4 runbooks, found {len(names)}: {names}"

check("SSM runbooks exist (Day 32)", check_runbooks)

# Summary
print()
passed = sum(1 for _, r in results if r == 'PASS')
failed = sum(1 for _, r in results if r == 'FAIL')
print(f"Infrastructure: {passed} passed, {failed} failed")
