# Secrets Management with KMS & Secrets Manager

### Components Created

**KMS Key:**
- Purpose: Encrypt secrets at rest
- Key rotation: Enabled
- Deletion window: 7 days
- Alias: myapp-secrets-key

**Secrets Manager (4 secrets):**
1. Database credentials (username, password, host, port)
2. API keys (Stripe, SendGrid, GitHub)
3. Application config (JWT, encryption, session keys)
4. SSL/TLS certificates (cert, private key, CA bundle)

**SSM Parameter Store (5 parameters):**
1. Database endpoint (String)
2. Database name (String)
3. Database password (SecureString with KMS)
4. API base URL (String)
5. Feature flags (StringList)

### Secrets vs Parameters

**Use Secrets Manager for:**
- Credentials that need rotation
- Complex JSON structures
- Automatic rotation support
- Cross-account access

**Use SSM Parameter Store for:**
- Simple configuration values
- Non-sensitive settings
- Cost optimization (Standard tier free)
- Environment variables

### Encryption At Rest

All secrets are encrypted using KMS:
- Secrets Manager: Automatic KMS encryption
- SSM SecureString: KMS encryption specified

### Secret Retrieval

**Secrets Manager:**
```python
response = secrets_client.get_secret_value(SecretId='myapp/database/credentials')
secret = json.loads(response['SecretString'])
```

**SSM Parameter Store:**
```python
response = ssm_client.get_parameter(
    Name='/myapp/dev/database/password',
    WithDecryption=True
)
value = response['Parameter']['Value']
```

### Secret Rotation

**Manual Rotation:**
```python
secrets_client.put_secret_value(
    SecretId='myapp/database/credentials',
    SecretString=json.dumps(new_credentials)
)
```

**Automatic Rotation:**
Requires Lambda function (not implemented in Day 23).

### KMS Key Policy

Allows:
- Root account full access
- Secrets Manager and SSM to decrypt
- Services to create grants

### Best Practices

1. Separate secrets by environment
2. Use descriptive naming conventions
3. Enable key rotation
4. Set appropriate recovery windows
5. Tag all secrets
6. Use IAM policies to restrict access
7. Audit secret access with CloudTrail
8. Rotate credentials regularly

### Security Benefits

- Encryption at rest (KMS)
- Encryption in transit (TLS)
- Versioning (rollback capability)
- Audit trail (CloudTrail)
- Fine-grained access control (IAM)
- Automatic rotation support

### Cost Considerations

**Secrets Manager:**
- $0.40 per secret per month
- $0.05 per 10,000 API calls

**SSM Parameter Store:**
- Standard: Free up to 10,000 parameters
- Advanced: $0.05 per parameter per month

**KMS:**
- $1 per key per month
- $0.03 per 10,000 requests

### Testing Commands
```bash
# List secrets
aws secretsmanager list-secrets

# Get secret value
aws secretsmanager get-secret-value --secret-id myapp/database/credentials

# List SSM parameters
aws ssm describe-parameters

# Get SSM parameter
aws ssm get-parameter --name /myapp/dev/database/endpoint

# Get encrypted parameter
aws ssm get-parameter --name /myapp/dev/database/password --with-decryption

# List KMS keys
aws kms list-keys

# Describe KMS key
aws kms describe-key --key-id <key-id>
```

### Next Steps

- Implement automatic rotation with Lambda
- Set up secret replication across regions
- Configure CloudTrail for audit logging
- Implement secret access policies
- Set up alerts for secret access
