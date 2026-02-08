# CloudFormation Change Sets Guide

## What Are Change Sets?

Change sets preview changes before updating a stack, showing what will be modified, added, or deleted.

## Why Use Change Sets?

1. **Safety**: Preview changes before applying
2. **Review**: Team can review proposed changes
3. **Approval**: Implement approval workflow
4. **Understanding**: See exact impact of template changes

## Creating a Change Set
```bash
aws cloudformation create-change-set \
    --stack-name my-stack \
    --change-set-name my-changes \
    --template-body file://template.yaml
```

## Reviewing Changes
```bash
aws cloudformation describe-change-set \
    --stack-name my-stack \
    --change-set-name my-changes
```

## Change Types

1. **Add**: New resource will be created
2. **Modify**: Existing resource will be updated
3. **Remove**: Resource will be deleted
4. **Dynamic**: Change depends on runtime conditions

## Replacement Behavior

- **Never**: Resource updated in place
- **Conditional**: Might require replacement
- **Always**: Resource will be replaced

## Executing a Change Set
```bash
aws cloudformation execute-change-set \
    --stack-name my-stack \
    --change-set-name my-changes
```

## Best Practices

1. Always create change sets for production updates
2. Review all changes with team
3. Delete unused change sets
4. Document approval process
5. Test changes in dev environment first
