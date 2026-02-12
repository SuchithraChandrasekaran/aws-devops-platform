# Week 2 Summary - Infrastructure as Code (IaC) Implementation

**Duration**: Days 8-14 (Feb 4-11, 2026)
**Domain**: Configuration Management & IaC

## Weekly Learning Outcomes

### IaC Tools Mastered
✓ CloudFormation (Days 8-10)
  - Basic resource definitions
  - Intrinsic functions (Ref, GetAtt, Sub)
  - Conditions and parameters
  - Nested stacks
  - Multi-environment deployments

✓ Terraform (Days 11-14)
  - Providers and resources
  - Module creation and reuse
  - State management
  - Remote backends (S3 + DynamoDB)
  - Workspaces concept

✓ Systems Manager (Day 13)
  - Parameter Store hierarchies
  - Parameter types and encryption
  - Integration with IaC tools

### Infrastructure Built

**CloudFormation** (Learning - Days 8-10):
- VPC with multi-environment support
- RDS nested stack (PostgreSQL)
- Environment-specific parameters

**Terraform** (Production approach - Days 11-14):
- VPC module (subnets, IGW, route tables)
- SSM Parameter Store module
- Remote state with locking
- Environment: dev

**Total Managed Resources**: 15+
- 1 VPC
- 2 Public Subnets
- 1 Internet Gateway
- 1 Route Table (+ 2 associations)
- 5+ SSM Parameters
- 1 S3 Bucket (state backend)
- 1 DynamoDB Table (state locking)

## Key Skills Developed

### Day 8: CloudFormation Basics
- Created first CloudFormation template
- Deployed VPC infrastructure
- Learned CFN resource syntax

### Day 9: Multi-Environment CloudFormation
- Implemented conditions for dev/prod
- Used parameters for customization
- Learned Fn::Sub, Fn::GetAtt

### Day 10: Nested Stacks
- Created RDS as nested stack
- Understood stack dependencies
- Learned cross-stack references

### Day 11: Terraform Basics
- Migrated from CloudFormation to Terraform
- Created reusable modules
- Configured LocalStack provider

### Day 12: State Management
- Set up remote S3 backend
- Implemented DynamoDB state locking
- Understood state file security

### Day 13: Parameter Store
- Stored application configuration in SSM
- Created parameter hierarchies
- Referenced parameters in IaC

### Day 14: Drift Detection & Sprint Review
- Implemented drift detection workflow
- Created automated drift checking script
- Fixed configuration drift
- Consolidated Week 2 learnings


### Infrastructure as Code
- 100% of infrastructure defined in code
- Zero manual resource creation
- Version controlled configurations
- Repeatable deployments

### Drift Detection
- Automated drift checking script
- Detection time: < 30 seconds
- Remediation time: < 1 minute

### Code Artifacts
```
aws-devops-platform/
├── infrastructure/
│   ├── cloudformation/          # Days 8-10 learning
│   │   ├── vpc/
│   │   └── database/
│   ├── terraform/                # Days 11-14 production
│   │   ├── modules/
│   │   │   ├── vpc/
│   │   │   └── ssm/
│   │   └── environments/dev/
│   └── localstack/
│       └── docker-compose.yml
└── tests/
    └── drift-detection/
        ├── check-drift.sh
        └── DRIFT-REPORT.md
```

## Comparison: CloudFormation vs Terraform

| Feature | CloudFormation | Terraform |
|---------|---------------|-----------|
| AWS Native | ✓ Yes | ✗ No |
| Multi-Cloud | ✗ No | ✓ Yes |
| State Management | Managed by AWS | Self-managed (S3) |
| Drift Detection | Limited in LocalStack | Excellent |
| Module Ecosystem | Limited | Extensive (Registry) |

