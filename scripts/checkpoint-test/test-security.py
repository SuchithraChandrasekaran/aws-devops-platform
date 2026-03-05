"""
Security Integration Test - Day 35 Checkpoint
Tests: IAM, KMS, Config, Lambda (Days 22-28)
"""

import boto3

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
print("Security Layer - Days 22-28")
print("=" * 55)

# IAM roles (Day 22)
def check_iam():
    iam = client('iam')
    roles = iam.list_roles()
    assert len(roles['Roles']) > 0, "No IAM roles found"

check("IAM roles exist", check_iam)

# KMS keys (Day 23)
def check_kms():
    kms = client('kms')
    keys = kms.list_keys()
    assert len(keys['Keys']) > 0, "No KMS keys found"

check("KMS keys exist", check_kms)

# Config rules (Day 25)
def check_config():
    config = client('config')
    rules = config.describe_config_rules()
    assert len(rules['ConfigRules']) >= 5, \
        f"Expected 5+ Config rules, found {len(rules['ConfigRules'])}"

check("AWS Config rules exist (5+ expected)", check_config)

# Lambda functions (Day 29)
def check_lambda():
    lam = client('lambda')
    functions = lam.list_functions()
    names = [f['FunctionName'] for f in functions['Functions']]
    expected = ['auto-stop-resources', 'auto-tag', 'backup-verify',
                'security-remediation', 'health-check']
    missing = [e for e in expected if not any(e in n for n in names)]
    assert len(missing) == 0, f"Missing Lambda functions: {missing}"

check("All 5 Lambda functions exist (Day 29)", check_lambda)

print()
passed = sum(1 for _, r in results if r == 'PASS')
failed = sum(1 for _, r in results if r == 'FAIL')
print(f"Security: {passed} passed, {failed} failed")
