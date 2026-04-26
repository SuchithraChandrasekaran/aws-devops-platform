
main 4: Monitoring and Logging

> Flow and sequence diagrams covering CloudWatch

---

## 1. CloudWatch Metrics, Alarms, and Actions

**Services Involved**: CloudWatch, SNS, EC2 Auto Scaling, Lambda, Systems Manager

```mermaid
flowchart TD
    Resource[AWS Resource\nEC2 / RDS / Lambda / ALB] -->|emits| Metrics[CloudWatch Metrics\nbuilt-in + custom]
    Metrics -->|evaluate| Alarm[CloudWatch Alarm\nOK / ALARM / INSUFFICIENT_DATA]

    Alarm -->|state: ALARM| Actions{Alarm Actions}
    Actions -->|notify| SNS[SNS Topic]
    Actions -->|scale| ASG[EC2 Auto Scaling]
    Actions -->|trigger| Lambda[Lambda Function]
    Actions -->|run| SSM[SSM OpsItem / Automation]

    Metrics -->|aggregate| Dashboard[CloudWatch Dashboard]
    Metrics -->|math expression| MetricMath[Metric Math\ncalculated metrics]
```

---

## 2. CloudWatch Logs — Ingestion and Processing Pipeline

**Services Involved**: CloudWatch Logs, Kinesis Data Firehose, S3, Lambda, OpenSearch

```mermaid
flowchart TD
    Sources[Log Sources] --> CWL[CloudWatch Log Groups]
    Sources --> EC2[EC2\nCloudWatch Agent]
    Sources --> Lambda2[Lambda\nauto log to CWL]
    Sources --> VPC[VPC Flow Logs]
    Sources --> CT[CloudTrail Logs]

    EC2 --> CWL
    Lambda2 --> CWL
    VPC --> CWL
    CT --> CWL

    CWL -->|subscription filter| Kinesis[Kinesis Data Firehose]
    CWL -->|subscription filter| Lambda3[Lambda\nreal-time processing]
    CWL -->|export task| S3[S3 Bucket\nlong-term storage]

    Kinesis -->|deliver| S3
    Kinesis -->|deliver| OpenSearch[OpenSearch\nlog analysis]
    Kinesis -->|deliver| Splunk[Splunk / 3rd party]
```

---

## 3. CloudWatch Agent — EC2 Custom Metrics and Logs

**Services Involved**: CloudWatch Agent, EC2, SSM Parameter Store, IAM, CloudWatch

```mermaid
flowchart TD
    SSMParam[SSM Parameter Store\nCloudWatch Agent Config] -->|fetch config| Agent[CloudWatch Agent\non EC2]
    IAMRole[IAM Instance Role\nCloudWatchAgentServerPolicy] -->|authorize| Agent

    Agent -->|collect| SysMetrics[System Metrics\nmem, disk, swap]
    Agent -->|collect| AppLogs[Application Logs\n/var/log/app.log etc]

    SysMetrics -->|push| CWMetrics[CloudWatch Custom Metrics\nCWAgent namespace]
    AppLogs -->|push| CWLogs[CloudWatch Log Groups]

    CWMetrics -->|alarm| Alarm[CloudWatch Alarm]
    CWLogs -->|metric filter| FilterMetric[Metric Filter\nerror count etc]
    FilterMetric -->|alarm| Alarm
```

---
