# VPC CloudFormation Template Guide

## Overview
This template creates a complete VPC infrastructure with:
- 1 VPC
- 2 Public subnets (across 2 AZs)
- 1 Internet Gateway
- Route tables
- Security group for web servers

## Parameters

### EnvironmentName
- Description: Environment identifier
- Valid values: dev, prod
- Default: dev

### VpcCIDR
- Description: IP range for VPC
- Default: 10.0.0.0/16

### PublicSubnet1CIDR
- Description: IP range for subnet 1
- Default: 10.0.1.0/24

### PublicSubnet2CIDR
- Description: IP range for subnet 2
- Default: 10.0.2.0/24

## Resources Created

1. VPC with DNS support
2. Internet Gateway
3. Two public subnets in different AZs
4. Public route table with internet route
5. Security group allowing HTTP, HTTPS, SSH

## Outputs

All outputs are exported for use in other stacks:
- VPCId
- PublicSubnet1Id
- PublicSubnet2Id
- WebSecurityGroupId

## Usage

Deploy dev environment:
```bash
./infrastructure/cloudformation/scripts/deploy-stack.sh dev
```

Deploy prod environment:
```bash
./infrastructure/cloudformation/scripts/deploy-stack.sh prod
```

## Cost
Using LocalStack: $0
