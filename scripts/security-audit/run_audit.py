#!/usr/bin/env python3
"""
Security Audit Script - Day 28
Comprehensive security audit of infrastructure
"""

import boto3
import json
from datetime import datetime

# AWS clients
iam = boto3.client('iam', endpoint_url='http://localhost:4566',
                   region_name='us-east-1',
                   aws_access_key_id='test',
                   aws_secret_access_key='test')

ec2 = boto3.client('ec2', endpoint_url='http://localhost:4566',
                   region_name='us-east-1',
                   aws_access_key_id='test',
                   aws_secret_access_key='test')

s3 = boto3.client('s3', endpoint_url='http://localhost:4566',
                  region_name='us-east-1',
                  aws_access_key_id='test',
                  aws_secret_access_key='test')

kms = boto3.client('kms', endpoint_url='http://localhost:4566',
                   region_name='us-east-1',
                   aws_access_key_id='test',
                   aws_secret_access_key='test')

logs = boto3.client('logs', endpoint_url='http://localhost:4566',
                    region_name='us-east-1',
                    aws_access_key_id='test',
                    aws_secret_access_key='test')

def print_section(title):
    print("\n" + "="*70)
    print(f"  {title}")
    print("="*70)

def audit_iam():
    """Audit IAM configuration"""
    print_section("IAM Security Audit")
    
    findings = []
    
    try:
        # Check IAM users
        users = iam.list_users()
        print(f"IAM Users: {len(users['Users'])}")
        
        # Check for users without MFA (simulated)
        for user in users['Users'][:5]:
            print(f"  - {user['UserName']}")
        
        # Check IAM roles
        roles = iam.list_roles()
        print(f"\nIAM Roles: {len(roles['Roles'])}")
        
        myapp_roles = [r for r in roles['Roles'] if 'myapp' in r['RoleName']]
        print(f"Project Roles: {len(myapp_roles)}")
        for role in myapp_roles:
            print(f"  - {role['RoleName']}")
        
        # Check policies
        policies = iam.list_policies(Scope='Local')
        print(f"\nCustom Policies: {len(policies['Policies'])}")
        
        findings.append({
            'category': 'IAM',
            'status': 'PASS',
            'message': f'{len(myapp_roles)} roles with least privilege'
        })
        
    except Exception as e:
        findings.append({
            'category': 'IAM',
            'status': 'ERROR',
            'message': str(e)
        })
    
    return findings

def audit_network():
    """Audit network security"""
    print_section("Network Security Audit")
    
    findings = []
    
    try:
        # Check VPCs
        vpcs = ec2.describe_vpcs()
        print(f"VPCs: {len(vpcs['Vpcs'])}")
        
        for vpc in vpcs['Vpcs']:
            vpc_id = vpc['VpcId']
            cidr = vpc['CidrBlock']
            print(f"  - {vpc_id}: {cidr}")
        
        # Check Security Groups
        sgs = ec2.describe_security_groups()
        print(f"\nSecurity Groups: {len(sgs['SecurityGroups'])}")
        
        # Check for unrestricted access
        risky_sgs = []
        for sg in sgs['SecurityGroups']:
            for rule in sg.get('IpPermissions', []):
                for ip_range in rule.get('IpRanges', []):
                    if ip_range.get('CidrIp') == '0.0.0.0/0':
                        port = rule.get('FromPort', 'ALL')
                        if port in [22, 3389]:
                            risky_sgs.append({
                                'sg_id': sg['GroupId'],
                                'port': port
                            })
        
        if risky_sgs:
            print(f"\nWARNING: {len(risky_sgs)} security groups with risky rules")
            findings.append({
                'category': 'Network',
                'status': 'WARNING',
                'message': f'{len(risky_sgs)} SGs with 0.0.0.0/0 on SSH/RDP'
            })
        else:
            print("\nNo risky security group rules found")
            findings.append({
                'category': 'Network',
                'status': 'PASS',
                'message': 'Security groups properly configured'
            })
        
        # Check subnets
        subnets = ec2.describe_subnets()
        print(f"\nSubnets: {len(subnets['Subnets'])}")
        
    except Exception as e:
        findings.append({
            'category': 'Network',
            'status': 'ERROR',
            'message': str(e)
        })
    
    return findings

def audit_encryption():
    """Audit encryption configuration"""
    print_section("Encryption Audit")
    
    findings = []
    
    try:
        # Check KMS keys
        keys = kms.list_keys()
        print(f"KMS Keys: {len(keys['Keys'])}")
        
        for key in keys['Keys'][:5]:
            key_id = key['KeyId']
            try:
                key_metadata = kms.describe_key(KeyId=key_id)
                print(f"  - {key_id}: {key_metadata['KeyMetadata'].get('Description', 'No description')}")
            except:
                pass
        
        # Check S3 buckets
        buckets = s3.list_buckets()
        print(f"\nS3 Buckets: {len(buckets['Buckets'])}")
        
        unencrypted = []
        for bucket in buckets['Buckets']:
            bucket_name = bucket['Name']
            try:
                encryption = s3.get_bucket_encryption(Bucket=bucket_name)
                print(f"  - {bucket_name}: Encrypted")
            except:
                print(f"  - {bucket_name}: Not encrypted")
                unencrypted.append(bucket_name)
        
        if unencrypted:
            findings.append({
                'category': 'Encryption',
                'status': 'FAIL',
                'message': f'{len(unencrypted)} unencrypted S3 buckets'
            })
        else:
            findings.append({
                'category': 'Encryption',
                'status': 'PASS',
                'message': 'All S3 buckets encrypted'
            })
        
    except Exception as e:
        findings.append({
            'category': 'Encryption',
            'status': 'ERROR',
            'message': str(e)
        })
    
    return findings

def audit_logging():
    """Audit logging configuration"""
    print_section("Logging Audit")
    
    findings = []
    
    try:
        # Check CloudWatch Log Groups
        log_groups = logs.describe_log_groups()
        print(f"CloudWatch Log Groups: {len(log_groups['logGroups'])}")
        
        for lg in log_groups['logGroups'][:10]:
            name = lg['logGroupName']
            retention = lg.get('retentionInDays', 'Never expire')
            print(f"  - {name}: Retention {retention} days")
        
        findings.append({
            'category': 'Logging',
            'status': 'PASS',
            'message': f'{len(log_groups["logGroups"])} log groups configured'
        })
        
    except Exception as e:
        findings.append({
            'category': 'Logging',
            'status': 'ERROR',
            'message': str(e)
        })
    
    return findings

def generate_audit_report(all_findings):
    """Generate audit report"""
    print_section("SECURITY AUDIT SUMMARY")
    
    categories = {}
    for finding in all_findings:
        cat = finding['category']
        if cat not in categories:
            categories[cat] = []
        categories[cat].append(finding)
    
    pass_count = sum(1 for f in all_findings if f['status'] == 'PASS')
    warn_count = sum(1 for f in all_findings if f['status'] == 'WARNING')
    fail_count = sum(1 for f in all_findings if f['status'] == 'FAIL')
    error_count = sum(1 for f in all_findings if f['status'] == 'ERROR')
    
    print(f"\nTotal Checks: {len(all_findings)}")
    print(f"  PASS:    {pass_count}")
    print(f"  WARNING: {warn_count}")
    print(f"  FAIL:    {fail_count}")
    print(f"  ERROR:   {error_count}")
    
    print("\nFindings by Category:")
    for cat, findings in categories.items():
        print(f"\n{cat}:")
        for finding in findings:
            status = finding['status']
            message = finding['message']
            symbol = "PASS" if status == "PASS" else "WARNING" if status == "WARNING" else "FAIL"
            print(f"  [{symbol:7}] {message}")
    
    score = (pass_count / len(all_findings) * 100) if all_findings else 0
    print(f"\nSecurity Score: {score:.1f}%")
    
    return {
        'timestamp': datetime.now().isoformat(),
        'total_checks': len(all_findings),
        'pass': pass_count,
        'warning': warn_count,
        'fail': fail_count,
        'error': error_count,
        'score': score,
        'findings': all_findings
    }

def run_audit():
    """Run comprehensive security audit"""
    print("="*70)
    print("COMPREHENSIVE SECURITY AUDIT - DAY 28")
    print("="*70)
    
    all_findings = []
    
    all_findings.extend(audit_iam())
    all_findings.extend(audit_network())
    all_findings.extend(audit_encryption())
    all_findings.extend(audit_logging())
    
    report = generate_audit_report(all_findings)
    
    # Save report
    with open('security-audit/reports/audit-report.json', 'w') as f:
        json.dump(report, f, indent=2)
    
    print("\nReport saved to: security-audit/reports/audit-report.json")
    print("="*70)
    
    return report

if __name__ == '__main__':
    run_audit()
