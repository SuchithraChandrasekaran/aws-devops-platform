# AWS DevOps Platform 

> A production-grade AWS DevOps platform built from scratch

---

## Overview

A complete **AWS DevOps platform** covering CI/CD automation, Infrastructure as Code, observability, security hardening, and cloud-native architecture — all deployed on AWS Free Tier.

---

## Tech Stack

- **CI/CD** — GitHub Actions, CodePipeline, Docker, Blue-Green deployments
- **IaC** — Terraform (modules, workspaces, remote state), CloudFormation (nested stacks, multi-env)
- **Observability** — CloudWatch, Prometheus, Grafana, EventBridge, SNS/SQS
- **Security** — IAM least-privilege, KMS encryption, SSM, VPC Flow Logs, Trivy, SonarCloud
- **Serverless** — Lambda (5 functions), Step Functions, auto-remediation
- **Database** — RDS PostgreSQL, DynamoDB, automated backups
- **Networking** — VPC, NGINX with SSL/TLS (Let's Encrypt), security groups

---

## Journey by Week

| Phase | Days | Focus |
|-------|------|-------|
| Week 1 | D1–D7 | LocalStack, VPC, Docker, CI/CD pipeline |
| Week 2 | D8–D14 | IaC — CloudFormation, Terraform modules, SSM |
| Week 3 | D15–D21 | Observability — CloudWatch, Prometheus, Grafana |
| Week 4 | D22–D28 | Security hardening — IAM, KMS, compliance |
| Week 5 | D29–D35 | Serverless, Step Functions, E2E testing |
| Week 6 | D36–D42 | AWS Free Tier deploy, RDS, CI/CD live |
| Week 7 | D43–D49 | Backups, lifecycle policies, EventBridge, Lambda |
| Week 8 | D50–D56 | CloudTrail, Config rules, NGINX SSL, Blue-Green |
| Week 9 | D57–D63 | Log aggregation, IAM audit, DR runbook, DynamoDB |
| Review | D64–D84 | Deep recall sprints across all domains |
| Final | D85–D92 | Flow diagrams, architecture diagrams, cheat sheets |

---

## Domain Coverage

### Domain 1 — SDLC Automation
CI/CD pipelines with GitHub Actions and CodePipeline, Docker containerization, blue-green deployments, Trivy security scanning, S3 artifact management.

### Domain 2 — Configuration Management & IaC
Terraform modules, workspaces, and remote state. CloudFormation nested stacks and multi-environment templates. SSM Parameter Store for config management.

### Domain 3 — Resilient Cloud Solutions
Auto-scaling simulation, Step Functions for DR orchestration, SNS/SQS fan-out messaging with DLQ, RDS with automated snapshots.

### Domain 4 — Monitoring & Logging
CloudWatch custom metrics, dashboards, and alarms. Prometheus + Grafana stack. Centralized log aggregation and analysis. EventBridge automation.

### Domain 5 — Incident & Event Response
Lambda auto-remediation, EventBridge rules, SSM runbooks, SNS alerting to email/SMS, DR runbook automation.

### Domain 6 — Security & Compliance
IAM least-privilege, KMS encryption, VPC Flow Logs, security group auditing, CloudTrail logging, AWS Config rules, cost allocation tags.

---

## Deliverables

- **Flow diagrams** for all 6 AWS DevOps domains
- **Architecture diagrams** for the full platform
- **Cheat sheets** summarizing key concepts and commands
- **Recall sprints** covering every major topic

---

