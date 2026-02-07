# CloudFormation Conditions Guide

## What Are Conditions?

Conditions control whether resources are created or how they're configured based on parameter values.

## Syntax
```yaml
Conditions:
  ConditionName: !Equals [!Ref Parameter, Value]
```

## Common Condition Functions

### Fn::Equals
```yaml
IsProduction: !Equals [!Ref EnvironmentName, prod]
```

### Fn::And
```yaml
EnableHighAvailability: !And
  - !Condition IsProduction
  - !Condition CreateNATGateway
```

### Fn::Or
```yaml
EnableMonitoring: !Or
  - !Condition IsProduction
  - !Condition IsStaging
```

### Fn::Not
```yaml
IsDevelopment: !Not [!Condition IsProduction]
```

## Using Conditions

### In Resource Creation
```yaml
NATGateway:
  Type: AWS::EC2::NatGateway
  Condition: CreateNATGateway
```

### In Property Values
```yaml
Properties:
  Description: !If [IsProduction, 'Prod SG', 'Dev SG']
```

### In Outputs
```yaml
Outputs:
  NATGatewayId:
    Value: !If [CreateNATGateway, !Ref NATGateway, 'Not Created']
```

## Best Practices

1. Name conditions clearly (IsProduction, CreateNATGateway)
2. Keep condition logic simple
3. Document what each condition controls
4. Test both true and false paths
5. Use parameters to drive conditions

## Common Patterns

### Environment-Based Resources
```yaml
Conditions:
  IsProduction: !Equals [!Ref Environment, prod]

Resources:
  ExpensiveResource:
    Type: AWS::SomeResource
    Condition: IsProduction
```

### Feature Flags
```yaml
Parameters:
  EnableFeature:
    Type: String
    AllowedValues: ['true', 'false']

Conditions:
  FeatureEnabled: !Equals [!Ref EnableFeature, 'true']
```

### Multi-Condition Logic
```yaml
Conditions:
  IsProdAndNAT: !And
    - !Condition IsProduction
    - !Condition CreateNAT
```
