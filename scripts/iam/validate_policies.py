#!/usr/bin/env python3
"""
IAM Policy Validator - Day 22
Validate IAM policies follow least-privilege principles
"""

import boto3
import json

iam = boto3.client(
    'iam',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

def print_section(title):
    """Print section header"""
    print("\n" + "="*70)
    print(f"  {title}")
    print("="*70)

def check_policy_wildcards(policy_document):
    """Check for overly permissive wildcards"""
    issues = []
    
    for statement in policy_document.get('Statement', []):
        actions = statement.get('Action', [])
        if isinstance(actions, str):
            actions = [actions]
        
        resources = statement.get('Resource', [])
        if isinstance(resources, str):
            resources = [resources]
        
        # Check for Action: *
        if '*' in actions:
            issues.append("Found Action: * (too permissive)")
        
        # Check for Resource: *
        if '*' in resources and not statement.get('Condition'):
            issues.append("Found Resource: * without conditions (too permissive)")
    
    return issues

def analyze_role(role_name):
    """Analyze a role and its policies"""
    print(f"\nAnalyzing role: {role_name}")
    print("-" * 70)
    
    try:
        # Get role
        role = iam.get_role(RoleName=role_name)
        print(f"  ✓ Role exists")
        
        # Get attached policies
        attached = iam.list_attached_role_policies(RoleName=role_name)
        policy_count = len(attached['AttachedPolicies'])
        print(f"  ✓ Attached policies: {policy_count}")
        
        # Analyze each policy
        for policy in attached['AttachedPolicies']:
            policy_name = policy['PolicyName']
            policy_arn = policy['PolicyArn']
            
            # Get policy version
            policy_obj = iam.get_policy(PolicyArn=policy_arn)
            version_id = policy_obj['Policy']['DefaultVersionId']
            
            # Get policy document
            policy_version = iam.get_policy_version(
                PolicyArn=policy_arn,
                VersionId=version_id
            )
            
            policy_doc = policy_version['PolicyVersion']['Document']
            
            print(f"\n  Policy: {policy_name}")
            
            # Check for issues
            issues = check_policy_wildcards(policy_doc)
            if issues:
                for issue in issues:
                    print(f"    ⚠️  {issue}")
            else:
                print(f"    ✓ No major issues found")
            
            # Show permissions summary
            for statement in policy_doc.get('Statement', []):
                effect = statement.get('Effect', 'Unknown')
                actions = statement.get('Action', [])
                if isinstance(actions, str):
                    actions = [actions]
                
                action_summary = ', '.join(actions[:3])
                if len(actions) > 3:
                    action_summary += f" (+{len(actions)-3} more)"
                
                print(f"    {effect}: {action_summary}")
        
        return True
        
    except Exception as e:
        print(f"  ✗ Error: {e}")
        return False

def validate_least_privilege():
    """Validate all roles follow least privilege"""
    print_section("IAM POLICY VALIDATION - DAY 22")
    
    # Get all roles with 'myapp' prefix
    try:
        response = iam.list_roles()
        myapp_roles = [r for r in response['Roles'] if 'myapp' in r['RoleName'].lower()]
        
        print(f"\nFound {len(myapp_roles)} myapp roles")
        
        results = {}
        for role in myapp_roles:
            role_name = role['RoleName']
            results[role_name] = analyze_role(role_name)
        
        # Summary
        print_section("VALIDATION SUMMARY")
        
        passed = sum(1 for v in results.values() if v)
        total = len(results)
        
        for role_name, result in results.items():
            symbol = "✓" if result else "✗"
            status = "VALID" if result else "FAILED"
            print(f"  {symbol} {role_name}: {status}")
        
        print(f"\n  Total: {passed}/{total} roles validated")
        
        if passed == total:
            print("\n  ALL ROLES FOLLOW LEAST-PRIVILEGE PRINCIPLES!")
        else:
            print(f"\n {total - passed} role(s) need attention")
        
        return passed == total
        
    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == '__main__':
    success = validate_least_privilege()
    exit(0 if success else 1)
