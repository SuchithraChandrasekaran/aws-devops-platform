# CloudFormation Quick Reference

## Stack Operations

### Create Stack
```bash
aws cloudformation create-stack \
    --stack-name my-stack \
    --template-body file://template.yaml \
    --parameters file://parameters.json \
    --endpoint-url=http://localhost:4566 \
    --profile localstack
```

### Update Stack
```bash
aws cloudformation update-stack \
    --stack-name my-stack \
    --template-body file://template.yaml \
    --parameters file://parameters.json \
    --endpoint-url=http://localhost:4566 \
    --profile localstack
```

### Delete Stack
```bash
aws cloudformation delete-stack \
    --stack-name my-stack \
    --endpoint-url=http://localhost:4566 \
    --profile localstack
```

### Describe Stack
```bash
aws cloudformation describe-stacks \
    --stack-name my-stack \
    --endpoint-url=http://localhost:4566 \
    --profile localstack
```

### List Stacks
```bash
aws cloudformation list-stacks \
    --endpoint-url=http://localhost:4566 \
    --profile localstack
```

### Get Stack Outputs
```bash
aws cloudformation describe-stacks \
    --stack-name my-stack \
    --endpoint-url=http://localhost:4566 \
    --profile localstack \
    | jq -r '.Stacks[0].Outputs'
```

## Intrinsic Functions

### Ref
Reference a parameter or resource:
```yaml
!Ref MyParameter
!Ref MyResource
```

### GetAtt
Get attribute of a resource:
```yaml
!GetAtt MyResource.AttributeName
```

### Sub
Substitute variables:
```yaml
!Sub '${EnvironmentName}-vpc'
```

### Join
Join strings:
```yaml
!Join ['-', [!Ref EnvironmentName, 'vpc']]
```

### Select
Select from list:
```yaml
!Select [0, !GetAZs '']
```

### GetAZs
Get availability zones:
```yaml
!GetAZs ''
```
