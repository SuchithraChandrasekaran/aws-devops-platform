# CloudFormation Intrinsic Functions Reference

## Fn::Sub - String Substitution

Replace variables in strings.
```yaml
!Sub '${EnvironmentName}-vpc'
!Sub '${AWS::StackName}-resource'
```

## Fn::GetAtt - Get Resource Attributes

Get attributes from resources.
```yaml
!GetAtt VPC.CidrBlock
!GetAtt SecurityGroup.GroupId
```

## Fn::Ref - Reference Parameters or Resources

Reference parameter values or resource IDs.
```yaml
!Ref EnvironmentName
!Ref VPC
```

## Fn::Join - Concatenate Strings

Join strings with delimiter.
```yaml
!Join ['-', [!Ref EnvironmentName, 'vpc']]
!Join ['', ['arn:aws:s3:::', !Ref BucketName]]
```

## Fn::Select - Select from Array

Get item from list.
```yaml
!Select [0, !GetAZs '']
!Select [1, ['value1', 'value2', 'value3']]
```

## Fn::GetAZs - Get Availability Zones

Get list of AZs.
```yaml
!GetAZs ''
!GetAZs 'us-east-1'
```

## Fn::If - Conditional Values

Return value based on condition.
```yaml
!If [IsProduction, 'm5.large', 't3.micro']
!If [CreateResource, !Ref Resource, 'Not Created']
```

## Fn::Equals - Compare Values

Compare two values.
```yaml
!Equals [!Ref Environment, prod]
!Equals [!Ref EnableFeature, 'true']
```

## Fn::And - Logical AND

Combine conditions.
```yaml
!And
  - !Condition IsProduction
  - !Condition CreateBackup
```

## Fn::Or - Logical OR

Either condition true.
```yaml
!Or
  - !Condition IsProduction
  - !Condition IsStaging
```

## Fn::Not - Logical NOT

Negate condition.
```yaml
!Not [!Condition IsProduction]
```

## Common Combinations

### Environment-Specific Names
```yaml
!Sub '${EnvironmentName}-${AWS::StackName}-resource'
```

### Conditional Resource References
```yaml
!If [CreateNAT, !Ref NATGateway, !Ref InternetGateway]
```

### Multi-AZ Selection
```yaml
AvailabilityZone: !Select [0, !GetAZs '']
```

### Complex Substitution
```yaml
!Sub |
  #!/bin/bash
  echo "Environment: ${EnvironmentName}"
  echo "Region: ${AWS::Region}"
```

