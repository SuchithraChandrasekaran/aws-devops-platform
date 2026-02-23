"""
Custom AWS Config Rule - Required Tags Check
Checks if resources have required tags
"""

import json
import boto3

config = boto3.client('config')

REQUIRED_TAGS = ['Environment', 'Owner', 'Project']

def lambda_handler(event, context):
    """
    Main Lambda handler for Config rule evaluation
    """
    print(f"Event: {json.dumps(event)}")
    
    invoking_event = json.loads(event['invokingEvent'])
    configuration_item = invoking_event.get('configurationItem', {})
    
    resource_type = configuration_item.get('resourceType')
    resource_id = configuration_item.get('resourceId')
    tags = configuration_item.get('tags', {})
    
    # Check if all required tags are present
    compliance_type = 'COMPLIANT'
    annotation = 'All required tags present'
    
    missing_tags = []
    for tag in REQUIRED_TAGS:
        if tag not in tags:
            missing_tags.append(tag)
    
    if missing_tags:
        compliance_type = 'NON_COMPLIANT'
        annotation = f'Missing required tags: {", ".join(missing_tags)}'
    
    # Put evaluation
    evaluation = {
        'ComplianceResourceType': resource_type,
        'ComplianceResourceId': resource_id,
        'ComplianceType': compliance_type,
        'Annotation': annotation,
        'OrderingTimestamp': configuration_item.get('configurationItemCaptureTime')
    }
    
    try:
        config.put_evaluations(
            Evaluations=[evaluation],
            ResultToken=event['resultToken']
        )
    except Exception as e:
        print(f"Error putting evaluation: {e}")
    
    return {
        'statusCode': 200,
        'body': json.dumps(f'Evaluation complete: {compliance_type}')
    }
