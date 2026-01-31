# Day 2 - Complete VPC Infrastructure

## Architecture

Internet
|
↓
[Internet Gateway]
|
↓
[VPC: 10.0.0.0/16]
|
├── [Public Subnet: 10.0.1.0/24] (us-east-1a)
│   └── Security Group: Web-SG (ports 22,80,443,3000)
│
└── [Private Subnet: 10.0.2.0/24] (us-east-1b)
└── Security Group: App-SG (all TCP from VPC)

## Resources Created

### VPC
- **CIDR**: 10.0.0.0/16
- **DNS Support**: Enabled
- **DNS Hostnames**: Enabled
- **Tenancy**: Default

### Subnets
| Name | Type | CIDR | AZ | Auto-assign Public IP |
|------|------|------|----|-----------------------|
| DevOps-Public-Subnet | Public | 10.0.1.0/24 | us-east-1a | Yes |
| DevOps-Private-Subnet | Private | 10.0.2.0/24 | us-east-1b | No |

### Internet Gateway
- Attached to VPC
- Allows public subnet to reach internet

### Route Tables

**Public Route Table**:
| Destination | Target | Purpose |
|-------------|--------|---------|
| 10.0.0.0/16 | local | Internal VPC traffic |
| 0.0.0.0/0 | IGW | Internet access |

**Private Route Table**:
| Destination | Target | Purpose |
|-------------|--------|---------|
| 10.0.0.0/16 | local | Internal VPC traffic only |

### Security Groups

**Web Security Group (DevOps-Web-SG)**:
| Type | Protocol | Port | Source | Purpose |
|------|----------|------|--------|---------|
| Inbound | TCP | 22 | 0.0.0.0/0 | SSH access |
| Inbound | TCP | 80 | 0.0.0.0/0 | HTTP traffic |
| Inbound | TCP | 443 | 0.0.0.0/0 | HTTPS traffic |
| Inbound | TCP | 3000 | 0.0.0.0/0 | Node.js app |
| Outbound | All | All | 0.0.0.0/0 | All outbound |

**App Security Group (DevOps-App-SG)**:
| Type | Protocol | Port | Source | Purpose |
|------|----------|------|--------|---------|
| Inbound | TCP | 0-65535 | 10.0.0.0/16 | VPC internal only |
| Outbound | All | All | 0.0.0.0/0 | All outbound |

## Quick Commands
```bash
# Source environment variables
source vpc-ids.sh

# List all VPC resources
awslocal ec2 describe-vpcs --vpc-ids $VPC_ID
awslocal ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID"
awslocal ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID"
awslocal ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID"

# Verify connectivity
awslocal ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID"
```

## Files

- `vpc-ids.sh` - Environment variables for all resource IDs
- `vpc-summary.txt` - Human-readable summary
- `README.md` - This file

