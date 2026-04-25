# Domain 3: Resilient Cloud Solutions

> Flow and sequence diagrams covering high availability, fault tolerance, disaster recovery, auto scaling, and resilience patterns.

---

## 1. ECS Service Auto Scaling and Rolling Update

**Services Involved**: ECS, ALB, CloudWatch, Application Auto Scaling, ECR

```mermaid
flowchart TD
    ECR[ECR Image Update] -->|trigger| Pipeline[CodePipeline]
    Pipeline -->|deploy| ECS[ECS Service\nRolling Update]

    ECS -->|new task| NewTask[New Task\nlaunch + health check]
    NewTask -->|register| TG[ALB Target Group]
    TG -->|health check pass| Traffic[Receive Traffic]
    ECS -->|deregister old task| OldTask[Old Task Drained + Stopped]

    CW[CloudWatch Metric\nCPU / Memory / Request Count] -->|alarm| AppScaling[Application Auto Scaling]
    AppScaling -->|scale out| ECS
    AppScaling -->|scale in| ECS
```

## 2. Auto Scaling Group — Scale Out and Scale In Flow

**Services Involved**: EC2 Auto Scaling, CloudWatch, ALB, SNS

```mermaid
flowchart TD
    CW[CloudWatch Metric\nCPU / Request Count / Custom] -->|breach threshold| Alarm[CloudWatch Alarm]
    Alarm -->|scale out| ASG[Auto Scaling Group]
    ASG -->|launch| EC2[New EC2 Instance]
    EC2 -->|register| ALB[ALB Target Group]
    ALB -->|health check pass| Traffic[Receive Traffic]

    Alarm2[CloudWatch Alarm\nlow utilization] -->|scale in| ASG
    ASG -->|deregister| ALB
    ALB -->|connection draining| Drain[In-flight requests complete]
    Drain -->|terminate| Terminate[Instance Terminated]

    ASG -->|lifecycle hook| SNS[SNS / Lambda\nnotify on launch or terminate]
```

---

## 3. ASG Lifecycle Hooks

**Services Involved**: EC2 Auto Scaling, SQS, Lambda, SNS, SSM

```mermaid
sequenceDiagram
    participant ASG as Auto Scaling Group
    participant Hook as Lifecycle Hook
    participant SQS as SQS / SNS
    participant Lambda as Lambda Function
    participant Instance as EC2 Instance

    ASG->>Hook: Instance launch triggered
    Hook->>SQS: Send lifecycle notification
    SQS->>Lambda: Trigger Lambda
    Lambda->>Instance: Bootstrap (install agent, configure, join domain)
    Lambda->>ASG: complete-lifecycle-action (CONTINUE)
    ASG->>Instance: Move to InService

    Note over Hook,Instance: Default timeout: 1 hour. Heartbeat extends it.

    ASG->>Hook: Instance termination triggered
    Hook->>SQS: Send lifecycle notification
    SQS->>Lambda: Trigger Lambda
    Lambda->>Instance: Drain tasks, deregister, backup logs
    Lambda->>ASG: complete-lifecycle-action (CONTINUE)
    ASG->>Instance: Terminate
```

---

## 4. RDS Multi-AZ Failover Sequence

**Services Involved**: RDS, Route 53 (internal DNS), EC2, CloudWatch

```mermaid
sequenceDiagram
    participant App as Application
    participant DNS as Route 53 Internal DNS
    participant Primary as RDS Primary (AZ-a)
    participant Standby as RDS Standby (AZ-b)
    participant CW as CloudWatch

    App->>DNS: Resolve DB endpoint
    DNS->>Primary: Route to primary

    Note over Primary: AZ failure / maintenance

    Primary-->>CW: Health check failed
    CW->>RDS: Trigger failover
    RDS->>Standby: Promote standby to primary
    RDS->>DNS: Update endpoint to new primary
    DNS-->>App: New primary endpoint (60-120s)
    App->>Standby: Resume connections
```

---

## 5. Disaster Recovery Strategies

**Services Involved**: Route 53, RDS, S3, EC2, CloudFormation, Pilot Light / Warm Standby

```mermaid
flowchart TD
    DR[Disaster Recovery Strategy] --> Strategy{RTO / RPO}

    Strategy -->|highest RTO, lowest cost| Backup[Backup and Restore\nS3 backups + CFN redeploy]
    Strategy -->|moderate RTO| Pilot[Pilot Light\nCore services running\nscale on failover]
    Strategy -->|low RTO| Warm[Warm Standby\nScaled-down full stack\nscale up on failover]
    Strategy -->|near-zero RTO, highest cost| Active[Multi-Site Active-Active\nfull capacity in both regions]

    Backup -->|failover time| T1[Hours]
    Pilot -->|failover time| T2[Tens of minutes]
    Warm -->|failover time| T3[Minutes]
    Active -->|failover time| T4[Seconds]
```

---

## 6. Route 53 Failover Routing with Health Checks

**Services Involved**: Route 53, ALB, CloudWatch, SNS

```mermaid
flowchart TD
    User[User DNS Query] --> R53[Route 53]
    R53 -->|primary record| HC1[Health Check\nHTTP / HTTPS / TCP]
    HC1 -->|healthy| Primary[Primary ALB\nus-east-1]
    HC1 -->|unhealthy| Failover[Failover Record\nSecondary ALB / S3 Static]

    HC1 -->|status change| CW[CloudWatch Alarm]
    CW -->|notify| SNS[SNS Alert]

    R53 -->|routing policies| Policies[Weighted / Latency /\nGeolocation / Failover]
```

---

