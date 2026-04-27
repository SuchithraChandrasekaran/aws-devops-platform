# Domain 5: Incident and Event Response

> Flow and sequence diagrams covering incident detection, automated remediation and event-driven response patterns.

---

## 1. Incident Detection and Response — High Level Flow

**Services Involved**: CloudWatch, EventBridge, SNS, Lambda, SSM OpsCenter, PagerDuty

```mermaid
flowchart TD
    Detect[Detection Sources] --> CW[CloudWatch Alarm]
    Detect --> CT[CloudTrail Event]
    Detect --> GD[GuardDuty Finding]
    Detect --> Config[AWS Config Rule Violation]
    Detect --> SH[Security Hub Finding]

    CW --> EB[EventBridge]
    CT --> EB
    GD --> EB
    Config --> EB
    SH --> EB

    EB -->|route event| Response{Response Type}
    Response -->|notify| SNS[SNS Topic\nEmail / SMS / PagerDuty]
    Response -->|auto remediate| Lambda[Lambda Function]
    Response -->|run playbook| SSM[SSM Automation Runbook]
    Response -->|create ticket| OpsCenter[SSM OpsCenter\nOpsItem]
```

## 2. Lambda Dead Letter Queue — Failed Event Handling

**Services Involved**: Lambda, SQS, SNS, CloudWatch, EventBridge

```mermaid
flowchart TD
    Source[Event Source\nSNS / S3 / EventBridge] -->|async invoke| Lambda[Lambda Function]
    Lambda -->|attempt 1 fails| Retry1[Retry attempt 1\nwait interval]
    Retry1 -->|attempt 2 fails| Retry2[Retry attempt 2\nwait interval]
    Retry2 -->|still failing| DLQ[Dead Letter Queue\nSQS or SNS]

    DLQ -->|message arrives| CW[CloudWatch Alarm\nApproximateNumberOfMessagesVisible]
    CW -->|breach| Alert[SNS Alert\non-call engineer]
    DLQ -->|manual reprocess| Reprocess[Re-invoke Lambda\nafter fix deployed]
```

---

## 3. Config Rule — Non-Compliant Resource Auto Remediation

**Services Involved**: AWS Config, SSM Automation, EventBridge, Lambda, SNS

```mermaid
sequenceDiagram
    participant Resource as AWS Resource
    participant Config as AWS Config
    participant Rule as Config Rule
    participant SSM as SSM Automation
    participant SNS as SNS

    Resource->>Config: Configuration change detected
    Config->>Rule: Evaluate rule
    Rule-->>Config: NON_COMPLIANT

    Config->>SSM: Trigger remediation action
    SSM->>Resource: Apply fix (e.g. enable encryption, close port)
    Resource-->>SSM: Remediation result
    SSM-->>Config: Execution complete
    Config->>SNS: Notify compliance team
```

---

## 4. VPC Flow Logs — Network Incident Investigation

**Services Involved**: VPC Flow Logs, CloudWatch Logs, Athena, S3, GuardDuty

```mermaid
flowchart TD
    VPC[VPC / Subnet / ENI] -->|flow logs| Destination{Log Destination}

    Destination -->|option 1| CWL[CloudWatch Log Groups]
    Destination -->|option 2| S3[S3 Bucket]

    CWL -->|metric filter| CW[CloudWatch Alarm\nspike in REJECT traffic]
    CW -->|notify| SNS[SNS Alert]

    S3 -->|query| Athena[Athena\nSQL on flow logs]
    Athena -->|investigate| Analysis[Identify source IP\nport scan / data exfil]

    S3 -->|analyze| GD[GuardDuty\nauto ingestion]
    GD -->|finding| EB[EventBridge\nauto response]
```

