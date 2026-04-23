# Domain 1: SDLC Automation

> Flow and sequence diagrams covering CodePipeline, CodeBuild, CodeDeploy, blue-green deployments, event-driven automation, and related services.

---

## 1. CI/CD Pipeline Flow

**Key Services**: CodePipeline + CodeBuild + CodeDeploy integration, artifact handling.

```mermaid
flowchart LR
    GitHub[GitHub Repository] -->|webhook| GH_Actions[GitHub Actions]
    GH_Actions -->|docker build| Docker[Docker Build]
    Docker -->|push| ECR[ECR / LocalStack S3]
    ECR -->|trigger| CodePipeline[AWS CodePipeline]
    CodePipeline -->|source artifact| CodeBuild[AWS CodeBuild]
    CodeBuild -->|buildspec.yml| Test[Run Tests + Trivy Security]
    Test -->|pass| CodeDeploy[AWS CodeDeploy]
    CodeDeploy -->|deploy| EC2[EC2 Instance]
    EC2 -->|blue-green| ALB[ALB / NGINX]
```

---

## 2. Blue-Green Deployment Sequence

**Key Services**: Traffic shifting, rollback strategy, CodeDeploy deployment groups.

```mermaid
sequenceDiagram
    participant User
    participant ALB as Application Load Balancer
    participant Blue as Blue Environment (Current)
    participant Green as Green Environment (New)
    participant CodeDeploy as AWS CodeDeploy

    User->>ALB: HTTP Request
    ALB->>Blue: Route 100% Traffic

    Note over Blue,Green: Deployment Starts

    CodeDeploy->>Green: Deploy New Version
    Green->>Green: Run Health Checks
    Green-->>CodeDeploy: Health Check Passed

    CodeDeploy->>ALB: Shift Traffic (0% to 100%)
    ALB->>Green: Route All Requests

    CodeDeploy->>Blue: Keep for Rollback

    Note over Blue,Green: Blue Becomes Backup Environment
```

---

## 3. Event-Driven Automation Flow

**Key Services**: CloudWatch + EventBridge + Lambda + SSM for auto-remediation.

```mermaid
flowchart TD

	CW[CloudWatch Alarm]
	EventBridge[EventBridge Rule]
	Lambda[Auto-Remediation Lambda]
	SSM[SSM Automation Runbook]
	SNS[SNS Topic]
	Resource[EC2 / RDS / Security Group]
	Admin[Administrator]

    CW -->|state: ALARM| EventBridge
    EventBridge -->|trigger pattern| Lambda
    Lambda -->|execute| SSM
    SSM -->|remediate| Resource
    Lambda -->|publish| SNS
    SNS -->|email/sms| Admin

```

---

## 4. SNS + SQS Fan-out with Dead Letter Queue

**Key Services**: Fan-out pattern, DLQ configuration, Lambda event source mapping.

```mermaid
sequenceDiagram
    participant Publisher
    participant SNS as SNS Topic
    participant SQS1 as SQS Queue A
    participant SQS2 as SQS Queue B
    participant DLQ as Dead Letter Queue
    participant Lambda1 as Lambda Consumer 1
    participant Lambda2 as Lambda Consumer 2
    participant Admin

    Publisher->>SNS: Publish Message
    SNS->>SQS1: Fan-out Message
    SNS->>SQS2: Fan-out Message

    Lambda1->>SQS1: Poll Messages
    Lambda2->>SQS2: Poll Messages

    alt Processing Fails (Max Receives Exceeded)
        Lambda1-->>DLQ: Send to DLQ
        DLQ-->>Admin: Trigger Alert
    else Processing Success
        Lambda1->>Lambda1: Process and Delete
        Lambda2->>Lambda2: Process and Delete
    end
```

---

## 5. CloudFormation Nested Stacks Architecture

**Key Services**: Stack dependencies, exports, change sets, drift detection.

```mermaid
flowchart TD
    Root[Root Stack: main.yaml] -->|Nested| VPC[VPC Stack: vpc.yaml]
    Root -->|Nested| RDS[RDS Stack: rds.yaml]
    Root -->|Nested| App[App Stack: app.yaml]

    VPC -->|Export: VPC ID| VPC_ID[VPC_ID Output]
    RDS -->|DependsOn| VPC
    App -->|DependsOn| VPC
    App -->|DependsOn| RDS

    ChangeSet[Change Set] -->|review changes| Execute[Execute Change Set]
    Execute -->|detect| Drift[Drift Detection]
    Drift -->|remediate| DriftRemediation[Drift Remediation]
```

---

## 6. CodePipeline Multi-Stage with Manual Approval

**Key Services**: Manual approval action, stage transitions, pipeline execution modes.

```mermaid
flowchart LR
    Source[Source Stage\nCodeCommit / S3 / GitHub] -->|artifact| Build[Build Stage\nCodeBuild]
    Build -->|test artifact| Test[Test Stage\nCodeBuild]
    Test -->|pass| Approval[Manual Approval\nSNS Notification]
    Approval -->|approved| DeployStaging[Deploy Staging\nCodeDeploy]
    DeployStaging -->|smoke test| ApprovalProd[Manual Approval\nProd Gate]
    ApprovalProd -->|approved| DeployProd[Deploy Production\nCodeDeploy]
    Approval -->|rejected| Stop[Pipeline Stopped]
```

---

## 7. CodeDeploy Deployment Strategies

**Key Services**: AllAtOnce, HalfAtATime, OneAtATime, canary vs linear traffic shifting.

```mermaid
flowchart TD
    Start[Deployment Triggered] --> Type{Deployment Type}

    Type -->|EC2 / On-Prem| InPlace[In-Place Deployment]
    Type -->|Lambda / ECS| Canary[Traffic Shifting Deployment]

    InPlace --> Strategy{Strategy}
    Strategy -->|AllAtOnce| A[Deploy all instances\nfast, downtime risk]
    Strategy -->|HalfAtATime| B[Deploy 50% at a time\nreduced risk]
    Strategy -->|OneAtATime| C[Deploy one instance at a time\nslowest, safest]

    Canary --> Shift{Shift Type}
    Shift -->|Canary| D[10% traffic, wait, then 90%]
    Shift -->|Linear| E[Equal increments over time]
    Shift -->|AllAtOnce| F[100% traffic immediately]

    D --> Hooks[Lifecycle Hooks\nBeforeAllowTraffic / AfterAllowTraffic]
    E --> Hooks
```

---

## 8. CodeBuild buildspec.yml Execution Flow

**Key Services**: Build phases, environment variables, artifact upload, cache.

```mermaid
flowchart TD
    Trigger[CodePipeline / Manual Trigger] --> Provision[Provision Build Environment\nDocker Image / Compute Type]
    Provision --> Install[install phase\nRuntime versions, dependencies]
    Install --> PreBuild[pre_build phase\nLogin to ECR, set env vars]
    PreBuild --> Build[build phase\nCompile, docker build, run tests]
    Build --> PostBuild[post_build phase\nPush to ECR, package artifact]
    PostBuild --> Artifacts[Upload Artifacts\nto S3 / CodePipeline]
    Artifacts --> Cache[Save Cache\nS3 Cache Bucket]
    Build -->|failure| Reports[Test Reports\nCodeBuild Reports Group]
```

---

## 9. Elastic Beanstalk Deployment Policies

**Key Services**: Deployment policies, rolling updates, immutable vs blue-green.

```mermaid
flowchart TD
    Deploy[New Application Version] --> Policy{Deployment Policy}

    Policy --> AllAtOnce2[All at Once\nDowntime, fastest]
    Policy --> Rolling[Rolling\nBatch size %, no extra cost]
    Policy --> RollingHealth[Rolling with Additional Batch\nNo capacity reduction]
    Policy --> Immutable[Immutable\nNew ASG, safest in-place]
    Policy --> BGDeploy[Blue-Green\nSwap environment URLs]

    Immutable --> HealthCheck[Health Check on new instances]
    HealthCheck -->|pass| Swap[Swap into original ASG]
    HealthCheck -->|fail| Terminate[Terminate new instances\nZero impact]

    BGDeploy --> CNAME[CNAME Swap via Route 53]
```

---

## 10. CodeCommit Branch Protection and PR Flow

**Key Services**: Approval rule templates, triggers, notifications.

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant CC as CodeCommit
    participant Approval as Approval Rule Template
    participant Reviewer
    participant Pipeline as CodePipeline

    Dev->>CC: Push to feature branch
    Dev->>CC: Create Pull Request
    CC->>Approval: Apply approval rule (1 approver required)
    CC->>Reviewer: SNS Notification
    Reviewer->>CC: Review and Approve PR
    Dev->>CC: Merge to main
    CC->>Pipeline: Trigger pipeline (CloudWatch Event)
```

---

## 11. Artifact Flow through CodePipeline

**Key Services**: S3 artifact bucket, encryption, cross-account pipeline.

```mermaid
flowchart LR
    Source[Source Action] -->|output artifact| S3[S3 Artifact Bucket\nKMS Encrypted]
    S3 -->|input artifact| BuildAction[Build Action\nCodeBuild]
    BuildAction -->|output artifact| S3
    S3 -->|input artifact| DeployAction[Deploy Action\nCodeDeploy / CFN / EB]

    S3 -->|cross-account| AssumeRole[Assume Cross-Account Role]
    AssumeRole -->|decrypt artifact| KMS[KMS Key\nCustomer Managed]
```

---

## 12. Systems Manager Patch Manager Flow

**Key Services**: Patch baselines, maintenance windows, compliance reporting.

```mermaid
flowchart TD
    PatchBaseline[Patch Baseline\nOS + severity rules] --> MaintWindow[Maintenance Window\nschedule + targets]
    MaintWindow --> RunCommand[SSM Run Command\nAWS-RunPatchBaseline]
    RunCommand --> Instances[EC2 Instances\nvia SSM Agent]
    Instances -->|scan or install| PatchResult[Patch Compliance Result]
    PatchResult --> Config[AWS Config Rule\nec2-managedinstance-patch-compliance]
    Config -->|non-compliant| SNS2[SNS Alert]
```
