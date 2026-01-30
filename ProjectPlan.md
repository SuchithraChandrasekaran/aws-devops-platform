#  AWS DevOps Platform

> A comprehensive, zero-cost AWS DevOps learning platform

## Overview

This project is a **complete AWS DevOps Professional certification preparation platform** that combines hands-on infrastructure deployment, CI/CD automation, and comprehensive exam preparation—all designed to cost **zero dollars** (except the exam fee).

### Key Features

✅ **Zero-Cost Infrastructure**: LocalStack for local AWS simulation  
✅ **Real AWS Deployment**: Strategic use of AWS Free Tier  
✅ **Complete CI/CD Pipeline**: GitHub Actions → Docker → AWS  
✅ **Infrastructure as Code**: CloudFormation + Terraform  
✅ **Full Observability Stack**: CloudWatch, Prometheus, Grafana  
✅ **Security Hardened**: IAM, KMS, VPC best practices  
✅ **1,785+ Practice Questions**: Integrated throughout the journey  
✅ **Production-Ready**: Scalable, monitored, automated platform  

---
### Learning Approach

```
LocalStack (Days 1-35) → AWS Free Tier (Days 36-63) → Practice Exams (Days 64-90) → ExAM (Day 91)
     ↓                          ↓                              ↓                        ↓
  Safe Learning          Real-World Testing            Exam Mastery              Certification
```

---

##  Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           AWS DevOps Platform                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌──────────────┐      ┌──────────────┐      ┌──────────────┐          │
│  │   GitHub     │─────▶│GitHub Actions│─────▶│   Docker     │          │
│  │  Repository  │      │   Pipeline   │      │   Registry   │          │
│  └──────────────┘      └──────────────┘      └──────────────┘          │
│         │                      │                      │                  │
│         │                      ▼                      ▼                  │
│         │              ┌──────────────┐      ┌──────────────┐          │
│         │              │    Trivy     │      │  SonarCloud  │          │
│         │              │   Security   │      │  Code Quality│          │
│         │              └──────────────┘      └──────────────┘          │
│         │                      │                      │                  │
│         │                      └──────────┬───────────┘                  │
│         │                                 ▼                              │
│         │                      ┌──────────────────────┐                 │
│         └─────────────────────▶│  LocalStack / AWS    │                 │
│                                 │    Infrastructure    │                 │
│                                 └──────────────────────┘                 │
│                                            │                              │
│                    ┌───────────────────────┼───────────────────────┐    │
│                    │                       │                       │    │
│                    ▼                       ▼                       ▼    │
│            ┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│            │     VPC      │       │   Compute    │       │   Storage    │
│            │  Network     │       │   (EC2/ECS)  │       │   (S3/RDS)   │
│            └──────────────┘       └──────────────┘       └──────────────┘
│                    │                       │                       │    │
│                    └───────────────────────┼───────────────────────┘    │
│                                            │                              │
│                                            ▼                              │
│                                 ┌──────────────────────┐                 │
│                                 │   Monitoring Stack   │                 │
│                                 │ CloudWatch/Prometheus│                 │
│                                 └──────────────────────┘                 │
│                                            │                              │
│                                            ▼                              │
│                                 ┌──────────────────────┐                 │
│                                 │   Alerting & Auto-   │                 │
│                                 │    Remediation       │                 │
│                                 │  EventBridge+Lambda  │                 │
│                                 └──────────────────────┘                 │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘
```

### Infrastructure Components

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **IaC** | CloudFormation, Terraform | Infrastructure provisioning |
| **CI/CD** | GitHub Actions, CodePipeline | Automated deployments |
| **Compute** | EC2, Docker, ECS | Application hosting |
| **Storage** | S3, RDS (PostgreSQL), DynamoDB | Data persistence |
| **Networking** | VPC, Security Groups, NACLs | Network isolation |
| **Monitoring** | CloudWatch, Prometheus, Grafana | Observability |
| **Security** | IAM, KMS, Secrets Manager | Access control & encryption |
| **Automation** | Lambda, EventBridge, Step Functions | Event-driven workflows |

---

## 📁 Directory Structure

```
aws-devops-platform/
│
├── README.md                           # This file
├── LICENSE                             # MIT License
├── .gitignore                          # Git ignore rules
├── CHANGELOG.md                        # Version history
│
├── docs/                               # Documentation
│   ├── architecture/                   # Architecture diagrams
│   │   ├── high-level-architecture.png
│   │   ├── network-diagram.png
│   │   ├── ci-cd-pipeline.png
│   │   └── monitoring-stack.png
│   ├── setup/                          # Setup guides
│   │   ├── 01-localstack-setup.md
│   │   ├── 02-aws-account-setup.md
│   │   ├── 03-github-actions-setup.md
│   │   └── 04-monitoring-setup.md
│   ├── runbooks/                       # Operational runbooks
│   │   ├── incident-response.md
│   │   ├── disaster-recovery.md
│   │   ├── scaling-procedures.md
│   │   └── security-procedures.md
│   ├── exam-prep/                      # Exam preparation materials
│   │   ├── domain-1-sdlc-automation.md
│   │   ├── domain-2-configuration-mgmt.md
│   │   ├── domain-3-monitoring-logging.md
│   │   ├── domain-4-policies-standards.md
│   │   ├── domain-5-incident-response.md
│   │   ├── domain-6-security-compliance.md
│   │   ├── exam-tips.md
│   │   └── cheat-sheet.md
│   └── daily-logs/                     # Daily progress logs
│       ├── week-01-cicd.md
│       ├── week-02-iac.md
│       ├── week-03-monitoring.md
│       └── ... (continues to week-14)
│
├── infrastructure/                     # Infrastructure as Code
│   ├── localstack/                     # LocalStack configurations
│   │   ├── docker-compose.yml
│   │   ├── localstack-config.yml
│   │   └── init-scripts/
│   │       ├── 01-setup-vpc.sh
│   │       ├── 02-setup-iam.sh
│   │       └── 03-setup-s3.sh
│   ├── cloudformation/                 # CloudFormation templates
│   │   ├── vpc/
│   │   │   ├── vpc-template.yaml
│   │   │   ├── vpc-parameters-dev.json
│   │   │   └── vpc-parameters-prod.json
│   │   ├── compute/
│   │   │   ├── ec2-template.yaml
│   │   │   └── ecs-template.yaml
│   │   ├── database/
│   │   │   ├── rds-template.yaml
│   │   │   └── dynamodb-template.yaml
│   │   ├── storage/
│   │   │   └── s3-template.yaml
│   │   ├── monitoring/
│   │   │   ├── cloudwatch-alarms.yaml
│   │   │   └── cloudwatch-dashboards.yaml
│   │   ├── security/
│   │   │   ├── iam-roles.yaml
│   │   │   ├── kms-keys.yaml
│   │   │   └── security-groups.yaml
│   │   ├── cicd/
│   │   │   └── codepipeline-template.yaml
│   │   ├── nested-stacks/
│   │   │   └── master-stack.yaml
│   │   └── README.md
│   ├── terraform/                      # Terraform configurations
│   │   ├── modules/
│   │   │   ├── vpc/
│   │   │   │   ├── main.tf
│   │   │   │   ├── variables.tf
│   │   │   │   ├── outputs.tf
│   │   │   │   └── README.md
│   │   │   ├── ec2/
│   │   │   │   ├── main.tf
│   │   │   │   ├── variables.tf
│   │   │   │   └── outputs.tf
│   │   │   ├── rds/
│   │   │   │   ├── main.tf
│   │   │   │   ├── variables.tf
│   │   │   │   └── outputs.tf
│   │   │   ├── s3/
│   │   │   │   ├── main.tf
│   │   │   │   ├── variables.tf
│   │   │   │   └── outputs.tf
│   │   │   ├── iam/
│   │   │   │   ├── main.tf
│   │   │   │   ├── variables.tf
│   │   │   │   └── outputs.tf
│   │   │   └── monitoring/
│   │   │       ├── main.tf
│   │   │       ├── variables.tf
│   │   │       └── outputs.tf
│   │   ├── environments/
│   │   │   ├── dev/
│   │   │   │   ├── main.tf
│   │   │   │   ├── variables.tf
│   │   │   │   ├── terraform.tfvars
│   │   │   │   └── backend.tf
│   │   │   ├── prod/
│   │   │   │   ├── main.tf
│   │   │   │   ├── variables.tf
│   │   │   │   ├── terraform.tfvars
│   │   │   │   └── backend.tf
│   │   │   └── localstack/
│   │   │       ├── main.tf
│   │   │       ├── variables.tf
│   │   │       └── provider.tf
│   │   ├── terraform.tfstate           # (gitignored - remote state preferred)
│   │   ├── .terraform.lock.hcl
│   │   └── README.md
│   └── ssm-parameters/                 # SSM Parameter Store configs
│       ├── dev-parameters.json
│       └── prod-parameters.json
│
├── applications/                       # Application Code
│   ├── sample-app/                     # Main demo application
│   │   ├── src/
│   │   │   ├── index.js                # Node.js application
│   │   │   ├── routes/
│   │   │   ├── controllers/
│   │   │   ├── models/
│   │   │   └── utils/
│   │   ├── tests/
│   │   │   ├── unit/
│   │   │   ├── integration/
│   │   │   └── e2e/
│   │   ├── Dockerfile
│   │   ├── .dockerignore
│   │   ├── package.json
│   │   ├── package-lock.json
│   │   ├── jest.config.js
│   │   └── README.md
│   └── lambda-functions/               # Serverless functions
│       ├── auto-stop-resources/
│       │   ├── index.js
│       │   ├── package.json
│       │   └── README.md
│       ├── auto-tag-resources/
│       │   ├── index.js
│       │   ├── package.json
│       │   └── README.md
│       ├── backup-verification/
│       │   ├── index.py
│       │   ├── requirements.txt
│       │   └── README.md
│       ├── security-remediation/
│       │   ├── index.py
│       │   ├── requirements.txt
│       │   └── README.md
│       └── health-check/
│           ├── index.js
│           ├── package.json
│           └── README.md
│
├── cicd/                               # CI/CD Pipeline Configurations
│   ├── github-actions/
│   │   └── workflows/
│   │       ├── deploy-dev.yml
│   │       ├── deploy-prod.yml
│   │       ├── security-scan.yml
│   │       ├── terraform-plan.yml
│   │       ├── terraform-apply.yml
│   │       └── run-tests.yml
│   ├── buildspec/
│   │   ├── buildspec-build.yml         # CodeBuild build spec
│   │   ├── buildspec-test.yml          # CodeBuild test spec
│   │   └── buildspec-deploy.yml        # CodeBuild deploy spec
│   ├── appspec/
│   │   └── appspec.yml                 # CodeDeploy app spec
│   └── scripts/
│       ├── pre-deploy.sh
│       ├── post-deploy.sh
│       ├── validate-deployment.sh
│       └── rollback.sh
│
├── monitoring/                         # Monitoring & Observability
│   ├── cloudwatch/
│   │   ├── dashboards/
│   │   │   ├── application-dashboard.json
│   │   │   ├── infrastructure-dashboard.json
│   │   │   └── security-dashboard.json
│   │   ├── alarms/
│   │   │   ├── compute-alarms.json
│   │   │   ├── database-alarms.json
│   │   │   ├── application-alarms.json
│   │   │   └── cost-alarms.json
│   │   ├── log-groups/
│   │   │   └── log-insights-queries.json
│   │   └── metric-filters/
│   │       └── custom-metrics.json
│   ├── prometheus/
│   │   ├── prometheus.yml
│   │   ├── alerts.yml
│   │   └── recording-rules.yml
│   ├── grafana/
│   │   ├── dashboards/
│   │   │   ├── system-overview.json
│   │   │   ├── application-metrics.json
│   │   │   └── business-metrics.json
│   │   ├── datasources/
│   │   │   └── datasources.yml
│   │   └── docker-compose.yml
│   └── x-ray/
│       └── sampling-rules.json
│
├── security/                           # Security Configurations
│   ├── iam/
│   │   ├── policies/
│   │   │   ├── developer-policy.json
│   │   │   ├── cicd-policy.json
│   │   │   └── lambda-execution-policy.json
│   │   ├── roles/
│   │   │   ├── ec2-role.json
│   │   │   ├── lambda-role.json
│   │   │   └── codebuild-role.json
│   │   └── users/
│   │       └── service-accounts.json
│   ├── kms/
│   │   ├── key-policies.json
│   │   └── grants.json
│   ├── secrets/
│   │   └── secrets-template.json       # Template (no actual secrets!)
│   ├── vpc/
│   │   ├── security-groups.json
│   │   ├── nacls.json
│   │   └── flow-logs-config.json
│   ├── config-rules/
│   │   ├── managed-rules.json
│   │   └── custom-rules/
│   │       ├── encrypted-volumes-rule.py
│   │       └── approved-amis-rule.py
│   └── compliance/
│       ├── cis-benchmark-checklist.md
│       └── security-audit-report.md
│
├── automation/                         # Automation Scripts & Workflows
│   ├── eventbridge/
│   │   ├── rules/
│   │   │   ├── auto-stop-instances.json
│   │   │   ├── backup-trigger.json
│   │   │   └── security-alert.json
│   │   └── patterns/
│   │       └── event-patterns.json
│   ├── step-functions/
│   │   ├── disaster-recovery-workflow.json
│   │   ├── deployment-workflow.json
│   │   └── backup-workflow.json
│   ├── ssm/
│   │   ├── automation-documents/
│   │   │   ├── patch-instances.yaml
│   │   │   ├── restart-services.yaml
│   │   │   └── snapshot-volumes.yaml
│   │   └── run-command/
│   │       └── common-commands.sh
│   └── scripts/
│       ├── cleanup-old-snapshots.py
│       ├── rotate-keys.py
│       ├── cost-report.py
│       └── security-scan.sh
│
├── tests/                              # Testing Suite
│   ├── unit/
│   │   ├── application/
│   │   └── infrastructure/
│   ├── integration/
│   │   ├── cicd-pipeline-test.js
│   │   └── infrastructure-test.py
│   ├── e2e/
│   │   └── full-deployment-test.js
│   ├── security/
│   │   ├── trivy-scan-results/
│   │   └── sonarcloud-reports/
│   └── load/
│       └── load-test-scenarios/
│
├── practice-questions/                 # Exam Preparation
│   ├── by-domain/
│   │   ├── domain-1-sdlc/
│   │   │   ├── questions-01-50.md
│   │   │   └── answers-01-50.md
│   │   ├── domain-2-iac/
│   │   │   ├── questions-01-50.md
│   │   │   └── answers-01-50.md
│   │   ├── domain-3-monitoring/
│   │   │   ├── questions-01-50.md
│   │   │   └── answers-01-50.md
│   │   ├── domain-4-policies/
│   │   │   ├── questions-01-30.md
│   │   │   └── answers-01-30.md
│   │   ├── domain-5-incident-response/
│   │   │   ├── questions-01-40.md
│   │   │   └── answers-01-40.md
│   │   └── domain-6-security/
│   │       ├── questions-01-50.md
│   │       └── answers-01-50.md
│   ├── practice-exams/
│   │   ├── practice-exam-01.md         # 75 questions
│   │   ├── practice-exam-02.md
│   │   ├── practice-exam-03.md
│   │   ├── practice-exam-04.md
│   │   └── practice-exam-05.md
│   ├── scenarios/
│   │   └── complex-scenarios.md
│   └── tracking/
│       └── progress-tracker.xlsx       # Your uploaded file
│
├── deployments/                        # Deployment Artifacts
│   ├── dev/
│   │   └── deployment-history.json
│   ├── prod/
│   │   └── deployment-history.json
│   └── rollback-plans/
│       └── rollback-procedures.md
│
├── configs/                            # Configuration Files
│   ├── nginx/
│   │   ├── nginx.conf
│   │   └── ssl/
│   │       └── ssl.conf
│   ├── docker/
│   │   ├── docker-compose-dev.yml
│   │   ├── docker-compose-prod.yml
│   │   └── .env.example
│   └── aws/
│       ├── aws-cli-config
│       └── localstack-endpoints.json
│
├── backups/                            # Backup Configurations
│   ├── rds-backup-policy.json
│   ├── ebs-snapshot-policy.json
│   └── s3-lifecycle-policy.json
│
├── cost-optimization/                  # Cost Management
│   ├── free-tier-tracker.md
│   ├── cost-allocation-tags.json
│   ├── budgets.json
│   └── cost-reports/
│       └── monthly-cost-analysis.md
│
├── demos/                              # Demo Materials
│   ├── video-script.md
│   ├── presentation.pptx
│   └── screenshots/
│
└── scripts/                            # Utility Scripts
    ├── setup/
    │   ├── install-localstack.sh
    │   ├── setup-aws-cli.sh
    │   └── configure-git.sh
    ├── daily-tasks/
    │   ├── day-01-setup.sh
    │   ├── day-02-vpc.sh
    │   └── ... (continues to day-95)
    ├── helpers/
    │   ├── check-aws-costs.sh
    │   ├── validate-iac.sh
    │   ├── run-security-scan.sh
    │   └── generate-report.py
    └── cleanup/
        ├── destroy-localstack.sh
        ├── cleanup-aws-resources.sh
        └── reset-environment.sh
```
### Weekly Breakdown

#### **Weeks 1-4: LocalStack Foundation (Days 1-28)**
- **Week 1**: CI/CD Pipeline (CodeCommit, CodeBuild, CodeDeploy, CodePipeline)
- **Week 2**: Infrastructure as Code (CloudFormation, Terraform, SSM)
- **Week 3**: Monitoring & Logging (CloudWatch, Prometheus, Grafana, EventBridge)
- **Week 4**: Security & Compliance (IAM, KMS, Config, DevSecOps)

#### **Week 5: Automation Mastery (Days 29-35)**
- Lambda functions for auto-remediation
- EventBridge event-driven workflows
- Step Functions orchestration
- **Day 35 CHECKPOINT**: Core mastery complete (80% exam coverage)

#### **Weeks 6-9: AWS Free Tier Deployment (Days 36-63)**
- Real AWS infrastructure deployment
- Production CI/CD pipeline
- Full monitoring stack
- Security hardening
- **Day 63 CHECKPOINT**: Full platform live on AWS

#### **Weeks 10-13: Exam Preparation (Days 64-90)**
- 10+ full practice exams (75 questions each)
- Deep domain reviews
- Scenario-based practice
- Weak area targeting
- **Day 89**: Final practice exam (target 90%+)

#### **Week 14: Exam  

---

## Exam Domains

### Domain Coverage

| Domain | Weight | Topics | Questions in Plan |
|--------|--------|--------|-------------------|
| **Domain 1: SDLC Automation** | 22% | CI/CD, CodePipeline, Deployment Strategies | 300+ |
| **Domain 2: Configuration Mgmt & IaC** | 19% | CloudFormation, Terraform, Systems Manager | 350+ |
| **Domain 3: Monitoring & Logging** | 15% | CloudWatch, X-Ray, EventBridge | 250+ |
| **Domain 4: Policies & Standards** | 10% | Service Catalog, Config, Organizations | 200+ |
| **Domain 5: Incident & Event Response** | 18% | Lambda, Auto Scaling, DR | 300+ |
| **Domain 6: Security & Compliance** | 16% | IAM, KMS, Security Hub, GuardDuty | 385+ |

**Total: 1,785+ Practice Questions**

---

##  Prerequisites

### Required Software

```
# Core Tools
- Git 2.30+
- Docker 20.10+
- Docker Compose 2.0+
- Node.js 18+ (LTS)
- Python 3.9+
- AWS CLI v2
- Terraform 1.5+

# Optional but Recommended
- Visual Studio Code
- Postman
- jq (JSON processor)
```

### AWS Account Setup

```bash
# Free Tier Account
1. Create AWS account (if you don't have one)
2. Enable MFA on root account
3. Create IAM admin user
4. Set billing alarm at $1
5. Enable Cost Explorer

# Cost Control
- Set up AWS Budgets
- Enable billing alerts
- Monitor Free Tier usage daily
```

### LocalStack Setup

```bash
# Install LocalStack
docker pull localstack/localstack:latest

# Start LocalStack
docker run -d \
  --name localstack \
  -p 4566:4566 \
  -p 4510-4559:4510-4559 \
  -e SERVICES=ec2,s3,iam,cloudformation,lambda,rds,dynamodb \
  localstack/localstack

# Verify
curl http://localhost:4566/_localstack/health
```
## Cost Strategy

### Zero-Cost Approach

```
Phase 1 (Days 1-35): LocalStack
├── Cost: $0.00
├── Method: Local Docker container
└── Services: All AWS services simulated locally

Phase 2 (Days 36-63): AWS Free Tier
├── Cost: $0.00 - $5.00
├── Method: Strategic use of free tier limits
└── Services:
    ├── EC2: 750 hours/month (t2.micro)
    ├── RDS: 750 hours/month (db.t2.micro)
    ├── S3: 5GB standard storage
    ├── CloudWatch: 10 metrics, 10 alarms
    └── Lambda: 1M requests, 400K GB-seconds

Phase 3 (Days 64-90): Practice Exams

Phase 4 (Day 91): Exam

```

### Cost Control Measures

```bash
# Daily Cost Checks
./scripts/helpers/check-aws-costs.sh

# Automated Alerts
- Billing alarm at $1
- AWS Budget: $5/month
- SNS email notifications

# Resource Management
- Stop RDS when not in use (saves 16 hrs/day)
- Use t2.micro instances only
- Delete unused snapshots
- Leverage S3 lifecycle policies
```

---

##  Technologies

### Core Stack

#### Infrastructure
- **LocalStack**: Local AWS cloud stack
- **CloudFormation**: AWS native IaC
- **Terraform**: Multi-cloud IaC
- **AWS CDK**: (Optional) Programmatic IaC

#### Compute & Containers
- **Docker**: Containerization
- **EC2**: Virtual machines
- **ECS**: Container orchestration (optional)
- **Lambda**: Serverless functions

#### CI/CD
- **GitHub Actions**: Primary CI/CD
- **AWS CodePipeline**: Native AWS pipeline
- **AWS CodeBuild**: Build service
- **AWS CodeDeploy**: Deployment service

#### Monitoring & Observability
- **CloudWatch**: AWS native monitoring
- **Prometheus**: Metrics collection
- **Grafana**: Visualization
- **X-Ray**: Distributed tracing (theory)

#### Storage & Databases
- **S3**: Object storage
- **RDS**: Relational database (PostgreSQL)
- **DynamoDB**: NoSQL database

#### Security
- **IAM**: Identity & access management
- **KMS**: Key management
- **Secrets Manager**: Secrets storage
- **AWS Config**: Compliance as code
- **Trivy**: Container security scanning
- **SonarCloud**: Code quality

#### Automation
- **EventBridge**: Event-driven automation
- **Step Functions**: Workflow orchestration
- **Lambda**: Serverless automation
- **Systems Manager**: Operations management

---

### Sprint Reviews (Weekly)

Every 7 days, complete a sprint review:

1. Review all completed tasks
2. Test integrated components
3. Refactor code if needed
4. Update documentation
5. Assess learning gaps
6. Plan next week

---

### Documentation
- [AWS DevOps Blog](https://aws.amazon.com/blogs/devops/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [AWS Whitepapers](https://aws.amazon.com/whitepapers/)
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [LocalStack Documentation](https://docs.localstack.cloud/)

### Community
- [AWS DevOps Subreddit](https://www.reddit.com/r/aws/)
- [AWS Certification Discord](https://discord.gg/aws-certification)
- Stack Overflow: `[amazon-web-services] [devops]`

---

##  Contributing

This is a personal learning project, but if you find it useful and want to contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-improvement`)
3. Commit changes (`git commit -m 'Add amazing improvement'`)
4. Push to branch (`git push origin feature/amazing-improvement`)
5. Open a Pull Request

### Contribution Areas
- Additional practice questions
- Improved IaC templates
- Better automation scripts
- Documentation improvements
- Bug fixes

### When Stuck

1. Check the daily logs in `docs/daily-logs/`
2. Review the runbooks in `docs/runbooks/`
3. Search the practice questions for similar scenarios
4. Ask in AWS community forums
5. Review AWS documentation


