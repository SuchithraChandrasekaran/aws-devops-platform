# CloudFormation StackSets Overview

## What Are StackSets?

StackSets extend CloudFormation to deploy stacks across multiple AWS accounts and regions.

## Key Concepts

1. **Stack Set**: Template + parameters for multi-account/region deployment
2. **Stack Instances**: Individual stack deployments in target accounts/regions
3. **Organizational Units**: Deploy to all accounts in an OU

## Use Cases

1. **Multi-account governance**: Security baselines across accounts
2. **Multi-region deployment**: Deploy same infrastructure to multiple regions
3. **Compliance**: Ensure consistent configurations
4. **DR setup**: Replicate infrastructure across regions

## Deployment Targets

- Specific AWS accounts
- Organizational Units (OUs)
- Specific regions

## Operation Types

1. **Create**: Deploy new stack instances
2. **Update**: Update existing instances
3. **Delete**: Remove instances
4. **Detect drift**: Check for configuration drift

## Best Practices

1. Start with small deployments
2. Use service-managed permissions when possible
3. Monitor deployment progress
4. Test in non-production accounts first
5. Document account/region targets
