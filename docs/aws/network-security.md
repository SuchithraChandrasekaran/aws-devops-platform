# Network Security Architecture

### VPC Architecture

**CIDR:** 10.0.0.0/16

**Subnets:**
- Public Subnet 1: 10.0.1.0/24 (us-east-1a)
- Public Subnet 2: 10.0.2.0/24 (us-east-1b)
- Private Subnet 1: 10.0.11.0/24 (us-east-1a)
- Private Subnet 2: 10.0.12.0/24 (us-east-1b)

### Security Groups (Stateful)

**ALB Security Group:**
- Inbound: HTTP (80), HTTPS (443) from 0.0.0.0/0
- Outbound: All traffic

**Application Security Group:**
- Inbound: HTTP (80), App (8080) from ALB SG
- Inbound: SSH (22) from Bastion SG
- Outbound: All traffic

**Database Security Group:**
- Inbound: PostgreSQL (5432), MySQL (3306) from App SG
- Outbound: All traffic

**Bastion Security Group:**
- Inbound: SSH (22) from specific IPs
- Outbound: All traffic

### Network ACLs (Stateless)

**Public NACL:**
- Inbound: HTTP (80), HTTPS (443), SSH (22), Ephemeral (1024-65535)
- Outbound: All traffic

**Private NACL:**
- Inbound: All from VPC CIDR, Ephemeral ports (1024-65535)
- Outbound: All traffic

### Security Groups vs NACLs

| Feature | Security Groups | NACLs |
|---------|----------------|--------|
| Level | Instance | Subnet |
| State | Stateful | Stateless |
| Rules | Allow only | Allow and Deny |
| Order | All rules evaluated | Rules in order |
| Return traffic | Automatic | Must be explicitly allowed |

### VPC Flow Logs

**Purpose:** Network traffic monitoring and analysis

**Captured Data:**
- Source/destination IP addresses
- Source/destination ports
- Protocol
- Action (ACCEPT/REJECT)
- Bytes/packets transferred

**Log Format:**
version account-id interface-id srcaddr dstaddr srcport dstport protocol packets bytes start end action log-status
**Use Cases:**
- Troubleshoot connectivity issues
- Detect suspicious activity
- Audit network access
- Monitor bandwidth usage

### Network Security Best Practices

1. Use multiple availability zones
2. Separate public and private subnets
3. Implement defense in depth (SG + NACL)
4. Use bastion hosts for SSH access
5. Enable VPC Flow Logs
6. Restrict security group rules to minimum
7. Use security group chaining
8. Regular security group audits
9. Enable DNS hostnames and resolution
10. Use private subnets for databases
