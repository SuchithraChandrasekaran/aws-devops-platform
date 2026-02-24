"""
Security Group Auto-Remediation Lambda
Automatically fixes overly permissive security group rules
"""

import json
import boto3

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    """
    Remediate security group issues
    """
    print(f"Event: {json.dumps(event)}")
    
    finding = event.get('detail', {})
    finding_type = finding.get('type', '')
    
    if 'UnauthorizedAccess:EC2' in finding_type:
        remediate_security_group(finding)
    elif 'Recon:EC2' in finding_type:
        isolate_instance(finding)
    else:
        print(f"No remediation for finding type: {finding_type}")
    
    return {
        'statusCode': 200,
        'body': json.dumps('Remediation completed')
    }

def remediate_security_group(finding):
    """Remove overly permissive security group rules"""
    try:
        resource = finding.get('resource', {})
        instance_id = resource.get('instanceDetails', {}).get('instanceId')
        
        if not instance_id:
            print("No instance ID found")
            return
        
        # Get instance security groups
        response = ec2.describe_instances(InstanceIds=[instance_id])
        
        if not response['Reservations']:
            print(f"Instance {instance_id} not found")
            return
        
        security_groups = response['Reservations'][0]['Instances'][0]['SecurityGroups']
        
        for sg in security_groups:
            sg_id = sg['GroupId']
            
            # Get security group rules
            sg_details = ec2.describe_security_groups(GroupIds=[sg_id])
            
            for permission in sg_details['SecurityGroups'][0]['IpPermissions']:
                # Check for 0.0.0.0/0 on risky ports
                for ip_range in permission.get('IpRanges', []):
                    if ip_range.get('CidrIp') == '0.0.0.0/0':
                        from_port = permission.get('FromPort', 0)
                        
                        # Remove SSH (22) and RDP (3389) from internet
                        if from_port in [22, 3389]:
                            print(f"Removing 0.0.0.0/0 access on port {from_port}")
                            
                            ec2.revoke_security_group_ingress(
                                GroupId=sg_id,
                                IpPermissions=[permission]
                            )
                            
                            print(f"Remediated: Removed public access to port {from_port}")
        
    except Exception as e:
        print(f"Error remediating security group: {e}")

def isolate_instance(finding):
    """Isolate compromised instance"""
    try:
        resource = finding.get('resource', {})
        instance_id = resource.get('instanceDetails', {}).get('instanceId')
        
        if not instance_id:
            print("No instance ID found")
            return
        
        # Create isolation security group
        vpc_id = get_instance_vpc(instance_id)
        
        if not vpc_id:
            return
        
        isolation_sg = create_isolation_security_group(vpc_id)
        
        # Replace instance security groups
        ec2.modify_instance_attribute(
            InstanceId=instance_id,
            Groups=[isolation_sg]
        )
        
        print(f"Instance {instance_id} isolated with security group {isolation_sg}")
        
    except Exception as e:
        print(f"Error isolating instance: {e}")

def get_instance_vpc(instance_id):
    """Get VPC ID for instance"""
    try:
        response = ec2.describe_instances(InstanceIds=[instance_id])
        return response['Reservations'][0]['Instances'][0]['VpcId']
    except Exception as e:
        print(f"Error getting VPC: {e}")
        return None

def create_isolation_security_group(vpc_id):
    """Create isolation security group with no inbound rules"""
    try:
        response = ec2.create_security_group(
            GroupName=f'isolation-sg-{vpc_id}',
            Description='Isolation security group for compromised instances',
            VpcId=vpc_id
        )
        
        sg_id = response['GroupId']
        
        # Remove default outbound rule
        ec2.revoke_security_group_egress(
            GroupId=sg_id,
            IpPermissions=[{
                'IpProtocol': '-1',
                'IpRanges': [{'CidrIp': '0.0.0.0/0'}]
            }]
        )
        
        return sg_id
        
    except Exception as e:
        print(f"Error creating isolation SG: {e}")
        return None
