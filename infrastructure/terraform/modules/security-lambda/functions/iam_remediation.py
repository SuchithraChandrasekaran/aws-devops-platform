"""
IAM Policy Auto-Remediation Lambda
Automatically fixes overly permissive IAM policies
"""

import json
import boto3

iam = boto3.client('iam')

DANGEROUS_ACTIONS = ['*', 'iam:*', 's3:*', 'ec2:*']

def lambda_handler(event, context):
    """
    Remediate IAM policy issues
    """
    print(f"Event: {json.dumps(event)}")
    
    finding = event.get('detail', {})
    finding_type = finding.get('type', '')
    
    if 'Policy:IAMUser' in finding_type:
        remediate_user_policy(finding)
    elif 'Policy:IAMRole' in finding_type:
        remediate_role_policy(finding)
    else:
        print(f"No remediation for finding type: {finding_type}")
    
    return {
        'statusCode': 200,
        'body': json.dumps('IAM remediation completed')
    }

def remediate_user_policy(finding):
    """Remove overly permissive user policies"""
    try:
        resource = finding.get('resource', {})
        user_name = resource.get('accessKeyDetails', {}).get('userName')
        
        if not user_name:
            print("No user name found")
            return
        
        # Get attached policies
        response = iam.list_attached_user_policies(UserName=user_name)
        
        for policy in response['AttachedPolicies']:
            policy_arn = policy['PolicyArn']
            
            if check_policy_dangerous(policy_arn):
                # Detach dangerous policy
                iam.detach_user_policy(
                    UserName=user_name,
                    PolicyArn=policy_arn
                )
                print(f"Detached dangerous policy {policy_arn} from user {user_name}")
        
        # Check inline policies
        inline_policies = iam.list_user_policies(UserName=user_name)
        
        for policy_name in inline_policies['PolicyNames']:
            policy_doc = iam.get_user_policy(
                UserName=user_name,
                PolicyName=policy_name
            )
            
            if has_dangerous_statements(policy_doc['PolicyDocument']):
                # Delete inline policy
                iam.delete_user_policy(
                    UserName=user_name,
                    PolicyName=policy_name
                )
                print(f"Deleted dangerous inline policy {policy_name} from user {user_name}")
        
    except Exception as e:
        print(f"Error remediating user policy: {e}")

def remediate_role_policy(finding):
    """Remove overly permissive role policies"""
    try:
        resource = finding.get('resource', {})
        role_name = resource.get('instanceDetails', {}).get('iamInstanceProfile', {}).get('arn', '').split('/')[-1]
        
        if not role_name:
            print("No role name found")
            return
        
        # Get attached policies
        response = iam.list_attached_role_policies(RoleName=role_name)
        
        for policy in response['AttachedPolicies']:
            policy_arn = policy['PolicyArn']
            
            if check_policy_dangerous(policy_arn):
                # Detach dangerous policy
                iam.detach_role_policy(
                    RoleName=role_name,
                    PolicyArn=policy_arn
                )
                print(f"Detached dangerous policy {policy_arn} from role {role_name}")
        
    except Exception as e:
        print(f"Error remediating role policy: {e}")

def check_policy_dangerous(policy_arn):
    """Check if policy contains dangerous permissions"""
    try:
        # Get policy version
        policy = iam.get_policy(PolicyArn=policy_arn)
        version_id = policy['Policy']['DefaultVersionId']
        
        # Get policy document
        policy_version = iam.get_policy_version(
            PolicyArn=policy_arn,
            VersionId=version_id
        )
        
        return has_dangerous_statements(policy_version['PolicyVersion']['Document'])
        
    except Exception as e:
        print(f"Error checking policy: {e}")
        return False

def has_dangerous_statements(policy_document):
    """Check if policy document has dangerous statements"""
    statements = policy_document.get('Statement', [])
    
    for statement in statements:
        if statement.get('Effect') != 'Allow':
            continue
        
        actions = statement.get('Action', [])
        if isinstance(actions, str):
            actions = [actions]
        
        resources = statement.get('Resource', [])
        if isinstance(resources, str):
            resources = [resources]
        
        # Check for dangerous combinations
        for action in actions:
            if action in DANGEROUS_ACTIONS and '*' in resources:
                return True
    
    return False
