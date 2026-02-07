# CloudFormation Nested Stacks Guide

## What Are Nested Stacks?

Nested stacks allow you to create reusable CloudFormation templates that are referenced from parent stacks.

## When to Use Nested Stacks

1. **Common patterns**: Reusable components like VPC, security groups
2. **Modular architecture**: Separate concerns (networking, database, compute)
3. **Template size limits**: Break large templates into smaller ones
4. **Team organization**: Different teams own different stacks

## Parent Stack Structure
```yaml
Resources:
  VPCStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: s3://bucket/vpc-template.yaml
      Parameters:
        VPCCidr: 10.0.0.0/16
```

## Cross-Stack References

Parent can reference nested stack outputs:
```yaml
VPCId: !GetAtt VPCStack.Outputs.VPCId
```

## Dependencies

Use DependsOn to control creation order:
```yaml
DatabaseStack:
  Type: AWS::CloudFormation::Stack
  DependsOn: VPCStack
```

## Best Practices

1. Use exports for cross-stack references
2. Version your nested templates
3. Test nested stacks independently first
4. Document dependencies clearly
5. Use descriptive output names
