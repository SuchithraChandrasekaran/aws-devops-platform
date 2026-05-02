# AWS DevOps Engineer Professional — Platform Project

A production-grade AWS DevOps platform, covering all 6 domains of the **AWS Certified DevOps Engineer – Professional** exam. Every component is deployed on AWS Free Tier using real infrastructure.

---

## Architecture Overview

> *(Add your architecture diagram image here — export from Day 90 and place in `/docs/architecture.png`)*

```
[ GitHub ] → [ CodePipeline / GitHub Actions ] → [ Docker Build ]
                                                        ↓
                                              [ Trivy Security Scan ]
                                                        ↓
                                         [ Blue-Green Deploy on EC2/ECS ]
                                                        ↓
                          ┌─────────────────────────────────────────┐
                          │  VPC  ·  RDS PostgreSQL  ·  DynamoDB    │
                          │  Lambda  ·  Step Functions  ·  S3        │
                          └─────────────────────────────────────────┘
                                                        ↓
                          [ CloudWatch · Prometheus · Grafana · SNS ]
```

---

## Domain Coverage

This project maps directly to all 6 domains of the **DOP-C02** exam guide:

### D1 · SDLC Automation — 22%
**Services:** CodeCommit, CodeBuild, CodeDeploy, CodePipeline, CodeArtifact, CodeGuru, ECR (lifecycle), ECS / EKS, Lambda (traffic shift), SAM / CDK, Elastic Beanstalk, GitHub Actions, buildspec.yml, AppSpec hooks

**What was built:**
- Full CI/CD pipeline with GitHub Actions and CodePipeline
- Blue-green, rolling, and canary deployment strategies
- Trivy container scanning and SonarCloud code quality gate
- Docker containerization with S3 artifact management
- CodeDeploy lifecycle hooks with automatic rollback

### D2 · Config Mgmt & IaC — 17%
**Services:** CloudFormation, StackSets (OUs), CDK (L2/L3), SAM templates, Terraform (remote state), SSM Parameter Store, Secrets Manager, AppConfig, Config Conformance Packs, CfCT Pipeline, Drift Detection, Nested Stacks, Custom Resources / Macros

**What was built:**
- Terraform modules, workspaces, and S3 remote state with DynamoDB locking
- CloudFormation nested stacks and multi-environment templates
- SSM Parameter Store for config management
- Drift detection and change set automation

### D3 · Resilient Cloud Solutions — 15%
**Services:** EC2 Auto Scaling, ALB / NLB / GWLB, Route 53 (health checks), CloudFront / WAF, RDS Multi-AZ, Aurora Global DB, DynamoDB Global Tables, S3 CRR / SRR, SQS DLQ / FIFO, Kinesis KDS / KDF, ElastiCache Redis, AWS Backup, DRS, Step Functions, SNS fanout

**What was built:**
- Auto-scaling simulation and blue-green deployment with Docker
- RDS automated backups and snapshots
- S3 lifecycle policies and versioning
- SNS/SQS fan-out messaging with Dead Letter Queues
- Step Functions DR orchestration (Pilot Light · Warm Standby · Active-Active)

### D4 · Monitoring & Logging — 15%
**Services:** CloudWatch Metrics / Alarms / Logs / Insights / Dashboards / Synthetics / Evidently / RUM, CloudTrail + Athena, X-Ray / ServiceLens, OpenSearch, Kinesis Firehose, Prometheus (AMP), Grafana (AMG), Container Insights, Lambda Insights, Trusted Advisor, Compute Optimizer

**What was built:**
- CloudWatch custom metrics, dashboards, and composite alarms
- Prometheus + Grafana stack for application-level observability
- Centralized log aggregation and structured log analysis
- EventBridge automation rules and SNS alerting to email/SMS
- CloudWatch Contributor Insights and anomaly detection

### D5 · Incident & Event Response — 14%
**Services:** EventBridge rules, EventBridge Pipes, SSM Run Command, SSM Automation, Lambda remediation, Step Functions, GuardDuty, Security Hub, Inspector v2, Detective, OpsCenter, Incident Manager, SQS DLQ reprocess, SNS fanout, ChatBot (ChatOps)

**What was built:**
- 5 Lambda auto-remediation functions deployed on real AWS
- EventBridge rules for event-driven automation
- SSM runbook and DR runbook automation
- Security group audit log and IAM audit log
- Key pattern: GuardDuty finding → EventBridge → Lambda isolate EC2

### D6 · Security & Compliance — 17%
**Services:** Control Tower, Landing Zone / AFT, SCPs (preventive), AWS Config rules, Organizations / OUs, IAM / STS / ABAC, KMS / CloudHSM, WAF / Shield Advanced, Macie, Secrets Manager, ACM / Private CA, Conformance Packs, RAM, SSO / Identity Center, Audit Manager, VPC Endpoints, PrivateLink

**What was built:**
- IAM least-privilege policies with permission boundaries
- KMS encryption for data at rest and cross-account key management
- CloudTrail logging and analysis; AWS Config rules for compliance
- Cost allocation tags and billing alarms
- NGINX with SSL/TLS via Let's Encrypt
- VPC Flow Logs and security group auditing

---

## Tech Stack

| Category | Tools |
|----------|-------|
| CI/CD | GitHub Actions, AWS CodePipeline, CodeBuild |
| Containers | Docker, Docker Compose |
| IaC | Terraform, AWS CloudFormation |
| Compute | EC2, Lambda (Python), Step Functions |
| Database | RDS PostgreSQL, DynamoDB |
| Networking | VPC, Subnets, Security Groups, NGINX |
| Monitoring | CloudWatch, Prometheus, Grafana, EventBridge |
| Security | IAM, KMS, SSM, CloudTrail, Trivy, SonarCloud |
| Messaging | SNS, SQS, EventBridge |
| Storage | S3 (artifacts, lifecycle policies, versioning) |

---

## Project Structure

```
aws-devops-platform/
├── .github/
│   └── workflows/          # GitHub Actions CI/CD pipelines
├── terraform/
│   ├── modules/            # Reusable Terraform modules
│   ├── workspaces/         # Multi-environment configs
│   └── remote-state/       # S3 backend + DynamoDB locking
├── cloudformation/
│   ├── vpc/                # VPC and networking templates
│   └── nested-stacks/      # Multi-environment nested stacks
├── lambda/                 # Auto-remediation Lambda functions
├── monitoring/
│   ├── cloudwatch/         # Dashboards, alarms, custom metrics
│   └── prometheus-grafana/ # Prometheus config + Grafana dashboards
├── security/               # IAM policies, KMS configs, audit scripts
├── docs/
│   ├── architecture.png    # Architecture diagram
│   ├── flow-diagrams/      # Domain flow diagrams (D84–D89)
│   └── cheatsheets/        # Quick reference cheat sheets
└── README.md
```

---

## How to Run Locally

### Prerequisites
- AWS CLI configured (`aws configure`)
- Terraform >= 1.0
- Docker
- Python 3.9+

### Quick Start

```bash
# Clone the repo
git clone https://github.com/suchithrachandrasekaran/aws-devops-platform.git
cd aws-devops-platform

# Initialize Terraform
cd terraform
terraform init
terraform workspace new dev
terraform plan

# Deploy to LocalStack (for local testing)
export AWS_ENDPOINT_URL=http://localhost:4566
docker-compose up -d
terraform apply -var-file="envs/dev.tfvars"
```

---

## The Build Log

| Phase | Days | Milestone |
|-------|------|-----------|
| Foundation | D0–D3 | LocalStack, VPC, Docker |
| CI/CD | D4–D7 | Full pipeline with GitHub Actions |
| IaC | D8–D14 | Terraform + CloudFormation complete |
| Observability | D15–D21 | CloudWatch + Prometheus + Grafana |
| Security | D22–D28 | IAM, KMS, compliance monitoring |
| Serverless | D29–D35 | Lambda, Step Functions, E2E tests |
| AWS Live | D36–D42 | Full deploy on real AWS Free Tier |
| Resilience | D43–D49 | Backups, lifecycle, EventBridge |
| Compliance | D50–D56 | CloudTrail, Config rules, SSL/TLS |
| Sprint 9 | D57–D63 | DR runbook, DynamoDB, audit logs |
| Recall | D64–D84 | Deep review across all 6 domains |
| Final | D85–D92 | Flow diagrams, architecture, cheat sheets |

---

## Key Deliverables

- **6 domain flow diagrams** — visual maps of each exam domain
- **Platform architecture diagram** — end-to-end system view
- **2 cheat sheets** — condensed reference for exam and practice
- **5 Lambda functions** — real auto-remediation deployed on AWS
- **Full IaC** — every resource defined in Terraform or CloudFormation
- **Zero AWS spend** — 100% Free Tier compliant

---

