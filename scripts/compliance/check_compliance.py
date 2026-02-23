#!/usr/bin/env python3
"""
Compliance Checker - Day 25
Check compliance status of AWS Config rules
"""

import boto3

config = boto3.client(
    'config',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

def get_config_rules():
    """Get all Config rules"""
    try:
        response = config.describe_config_rules()
        return response.get('ConfigRules', [])
    except Exception as e:
        print(f"Error getting rules: {e}")
        return []

def generate_compliance_report():
    """Generate compliance report"""
    print("="*70)
    print("AWS Config Compliance Report - Day 25")
    print("="*70)
    
    rules = get_config_rules()
    
    if not rules:
        print("\nNo Config rules found")
        return
    
    print(f"\nTotal Config Rules: {len(rules)}")
    print("-"*70)
    
    print("\nNote: LocalStack has limited Config compliance evaluation.")
    print("Rules are created but compliance checking is not fully implemented.")
    print("-"*70)
    
    for rule in rules:
        rule_name = rule['ConfigRuleName']
        rule_type = rule.get('Source', {}).get('Owner', 'UNKNOWN')
        source_id = rule.get('Source', {}).get('SourceIdentifier', 'N/A')
        
        print(f"CREATED  | {rule_name:40} | {rule_type:15}")
        print(f"           Source: {source_id}")
    
    print("\n" + "="*70)
    print("Summary")
    print("="*70)
    print(f"Total Rules Created: {len(rules)}")
    print(f"Managed Rules (AWS): {sum(1 for r in rules if r.get('Source', {}).get('Owner') == 'AWS')}")
    print(f"Custom Rules:        {sum(1 for r in rules if r.get('Source', {}).get('Owner') == 'CUSTOM_LAMBDA')}")
    
    print("\nIn real AWS, these rules would actively evaluate resources.")
    print("="*70)

if __name__ == '__main__':
    generate_compliance_report()
