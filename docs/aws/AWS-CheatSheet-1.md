# AWS DevOps Engineer Professional - Cheat Sheet Part 1

## Domains Covered in Part 1
- SDLC Automation (CI/CD)
- Configuration Management and IaC
- Monitoring and Logging

---

## 1. SDLC AUTOMATION (CI/CD)

### CodeCommit

- Managed Git repository service
- IAM-based authentication; SSH keys or HTTPS credentials per IAM user
- Supports triggers to SNS, Lambda on events (push, PR, branch create/delete)
- Cross-region replication not native; use CodePipeline or Lambda workaround
- Notifications via EventBridge or CodeCommit triggers
- Pull request approvals: define approval rule templates, apply to multiple repos
- Branch protection: IAM policy denying DeleteBranch or direct push to protected branches
- Mirror from GitHub: use periodic Lambda or GitHub Actions to sync

Key IAM permissions:
- `codecommit:GitPull`, `codecommit:GitPush`
- `codecommit:CreatePullRequest`, `codecommit:MergePullRequestByFastForward`

---

### CodeBuild

- Fully managed build service; no servers to manage
- Build spec: `buildspec.yml` at repo root or defined inline in project config
- Phases: `install`, `pre_build`, `build`, `post_build`
- Artifacts: uploaded to S3; can encrypt with KMS
- Caching: S3 cache or local cache (Docker layer, source, custom paths)
- Environment: managed images (Amazon Linux, Ubuntu, Windows) or custom Docker image from ECR/Docker Hub
- Concurrent builds: default soft limit 60 per region; request increase if needed
- VPC support: build runs inside your VPC for private resource access
- Environment variables: plaintext or from SSM Parameter Store or Secrets Manager (use parameter-store or secrets-manager type)
- Reports: test results (JUnit, NUnit, Cucumber), code coverage
- Batch builds: build graph, build list, build matrix

---

### CodeDeploy

- Deploys to EC2, on-premises, Lambda, ECS
- Agent required on EC2 and on-premises instances
- Deployment types:
  - In-place (EC2/on-prem only): stops app, deploys, restarts
  - Blue/Green: new fleet provisioned; traffic shifted; old fleet optionally terminated

Deployment configurations:
- AllAtOnce: all instances at once; fast but downtime risk
- HalfAtATime: half at a time
- OneAtATime: slowest; safest
- Custom: define minimum healthy hosts by count or percentage
- Lambda/ECS: Canary, Linear, AllAtOnce traffic shifting

AppSpec file:
- EC2/on-prem: YAML, defines files to copy and lifecycle hooks
- Lambda: YAML or JSON, defines function version and hooks
- ECS: YAML or JSON, defines task definition and load balancer config

EC2 AppSpec hooks (in order):
```
ApplicationStop -> DownloadBundle -> BeforeInstall -> Install ->
AfterInstall -> ApplicationStart -> ValidateService
```

Blue/Green additional hooks:
```
BeforeBlockTraffic -> BlockTraffic -> AfterBlockTraffic (on original)
BeforeAllowTraffic -> AllowTraffic -> AfterAllowTraffic (on replacement)
```

Rollback: automatic on CloudWatch alarm breach or deployment failure; manual rollback also possible

---

### CodePipeline

- Orchestrates CI/CD workflow; source-to-deploy automation
- Stages contain actions; actions can be parallel (run order) or sequential
- Action types: Source, Build, Test, Deploy, Approval, Invoke (Lambda)
- Artifact store: S3 bucket (encrypted with KMS); artifacts passed between stages
- Pipeline execution: triggered by source change, manual, scheduled (EventBridge)
- Cross-account pipelines: use cross-account IAM roles and shared KMS CMK for artifact bucket
- Cross-region actions: CodePipeline replicates artifacts to target region S3 bucket automatically
- V2 pipelines: support Git tags, branches as source triggers; more granular trigger filters
- Manual approval action: sends SNS notification; pipeline pauses until approved/rejected
- Execution modes (V2): Superseded (default), Queued, Parallel

Integrations:
- Source: CodeCommit, S3, GitHub (via CodeConnections), Bitbucket, GitLab
- Build: CodeBuild, Jenkins
- Deploy: CodeDeploy, CloudFormation, ECS, Elastic Beanstalk, S3, Service Catalog
- Invoke: Lambda, Step Functions

---

### CodeArtifact

- Managed artifact repository; compatible with npm, PyPI, Maven, NuGet, Swift, Cargo, Ruby
- Domains: top-level grouping; repositories belong to a domain
- Upstream repositories: chain repos; pull from public registries (npmjs, PyPI, Maven Central) via public upstream
- Asset retention: cached copies of public packages retained even if upstream removes them
- Cross-account: grant domain or repository permissions via resource-based policy
- Use with CodeBuild: set login token in pre_build phase

```bash
aws codeartifact get-authorization-token --domain mydomain --domain-owner 123456789 --query authorizationToken --output text
```

---

### Elastic Beanstalk

- PaaS; manages EC2, ELB, ASG, RDS, CloudWatch
- Supported platforms: Java, .NET, Node.js, Python, Ruby, PHP, Go, Docker, multicontainer Docker
- Deployment policies:
  - All at once: downtime; fastest
  - Rolling: partial downtime; no extra cost
  - Rolling with additional batch: no downtime; extra cost for extra instances during deploy
  - Immutable: new ASG; safe; most expensive; good for production
  - Blue/Green: swap environment URLs (Route 53 or CNAME swap); safest; extra cost
  - Traffic splitting: canary testing; route % traffic to new version

Configuration files: `.ebextensions/` directory; YAML/JSON files with `.config` extension
Order of precedence: direct API/console > saved config > `.ebextensions` > defaults

- `commands` run before app deployed; `container_commands` run after app extracted, before deployed
- `leader_only: true` runs command only on one instance (leader election)
- Worker environment: SQS-backed; periodic tasks via `cron.yaml`
- EB CLI: `eb create`, `eb deploy`, `eb health`, `eb ssh`, `eb logs`
- Lifecycle policy: automatically delete old app versions (by count or age) to avoid hitting 1000 version limit
- Managed platform updates: auto-apply platform patches during maintenance window
- Enhanced health reporting: uses EB health agent; 7 color-coded statuses; integrates with CloudWatch

---

### ECS and ECR (CI/CD Context)

- ECS deployment in CodePipeline: imagedefinitions.json or imageDetail.json
- imagedefinitions.json: array of `{"name": "container-name", "imageUri": "uri"}`
- imageDetail.json: for blue/green ECS deployments with CodeDeploy
- ECR lifecycle policies: automatically expire images by tag prefix, age, or count
- ECR image scanning: basic (on push) or enhanced (Inspector continuous scanning)
- ECR replication: cross-region and cross-account replication rules
- ECS task definition revision: immutable; create new revision to update

---

## 2. CONFIGURATION MANAGEMENT AND IaC

### CloudFormation

Core concepts:
- Stack: a single unit of related AWS resources
- Stack set: deploy stacks across multiple accounts and regions from a single template
- Change set: preview changes before executing an update
- Drift detection: detect manual changes to stack resources

Intrinsic functions:
- `!Ref` - parameter or resource ID
- `!GetAtt` - attribute of a resource
- `!Sub` - string substitution
- `!Join` - join strings
- `!Select` - select from list
- `!If` - conditional value
- `!FindInMap` - map lookup
- `!ImportValue` - cross-stack output import
- `!Split`, `!Cidr`, `!Base64`, `!Transform`

DeletionPolicy options: `Delete` (default), `Retain`, `Snapshot` (EBS, RDS, ElastiCache)
UpdateReplacePolicy: same options; applies when resource is replaced during update

Stack policies: JSON policy attached to stack; prevents unintended updates to specific resources
---

CloudFormation hooks: run custom logic before or after resource provisioning (CREATE, UPDATE, DELETE)
- Hook types: AWS::CloudFormation::Hook; written in Python or Java; published to CloudFormation registry
- Hook configuration: specify which stacks/resource types trigger the hook; set failure mode (FAIL or WARN)

Custom resources:
- `AWS::CloudFormation::CustomResource` or `Custom::MyName`
- Lambda-backed: Lambda receives event with `RequestType` (Create/Update/Delete), responds to pre-signed S3 URL
- Response must include `Status` (SUCCESS/FAILED), `PhysicalResourceId`, optional `Data` map

Nested stacks: `AWS::CloudFormation::Stack` resource; pass outputs as parameters; reusable modules
StackSets:
- Service-managed (Organizations integration): auto-deploy to new accounts in OUs
- Self-managed: requires admin role in management account and execution role in target accounts
- Deployment options: max concurrent percentage, failure tolerance percentage

CloudFormation Registry: third-party resource types and modules; published via CloudFormation CLI
Macros: `AWS::CloudFormation::Macro`; Lambda-backed; transform sections of template
`AWS::Serverless` transform (SAM): macro that transforms SAM resources to CloudFormation

---

### AWS SAM (Serverless Application Model)

- Extension of CloudFormation for serverless
- Resource types: `AWS::Serverless::Function`, `AWS::Serverless::Api`, `AWS::Serverless::SimpleTable`, `AWS::Serverless::StateMachine`, `AWS::Serverless::LayerVersion`, `AWS::Serverless::HttpApi`, `AWS::Serverless::Connector`
- `sam build`: packages code, downloads dependencies
- `sam local invoke`: local Lambda test
- `sam local start-api`: local API Gateway
- `sam local start-lambda`: local Lambda endpoint
- `sam deploy --guided`: interactive deploy wizard
- `sam pipeline init`: generate pipeline config for CodePipeline or other CI systems
- Globals section: set defaults for all functions (Timeout, MemorySize, Runtime, Environment)


---

### AWS CDK (Cloud Development Kit)

- Infrastructure as code using real programming languages (TypeScript, Python, Java, C#, Go)
- Constructs: L1 (Cfn* direct CloudFormation), L2 (higher-level with defaults), L3 (patterns)
- `cdk synth`: synthesize CloudFormation template
- `cdk deploy`: deploy stack
- `cdk diff`: show changes
- `cdk bootstrap`: deploy CDKToolkit stack (S3 bucket, ECR repo, IAM roles) in target account/region
- cdk.context.json: cached context values (VPC info, AMI IDs)
- Aspects: visit every construct in tree; useful for tagging, compliance checks
- CDK Pipelines: self-mutating pipeline using CodePipeline; adds stages with `addStage()`

---

### Terraform (exam awareness)

- State file: terraform.tfstate; store in S3 with DynamoDB locking for team use
- `terraform plan`: show what will change
- `terraform apply`: apply changes
- `terraform import`: bring existing resources under management
- Workspaces: separate state per workspace; useful for env separation
- Modules: reusable configuration blocks
- Providers: AWS, Azure, GCP etc.; configured with region, credentials

---

### AWS Config

- Continuous recording of resource configurations and changes
- Config rules: evaluate compliance (managed rules or custom Lambda rules)
- Evaluation triggers: configuration change, periodic (1h, 3h, 6h, 12h, 24h)
- Remediation: manual or auto (SSM Automation document)
- Aggregators: multi-account, multi-region view; requires authorization from source accounts
- Conformance packs: set of rules and remediation actions packaged as YAML template
- Delivery channel: S3 for snapshots/history, SNS for change notifications
- Configuration recorder: must be running to detect changes; one per region per account
- Retention: 7 years default; configurable

Useful managed rules:
- `restricted-ssh`, `restricted-common-ports`
- `s3-bucket-public-read-prohibited`, `s3-bucket-public-write-prohibited`
- `root-account-mfa-enabled`, `iam-password-policy`
- `encrypted-volumes`, `rds-storage-encrypted`
- `cloudtrail-enabled`, `guardduty-enabled-centralized`
- `required-tags`
- `ec2-instance-managed-by-ssm`

---

### Systems Manager (SSM)

Key capabilities for DevOps:

State Manager:
- Association: apply SSM documents to managed instances on schedule or event
- Used for: install agents, apply config baselines, run scripts on schedule
- Documents: command documents, policy documents, automation documents

Automation:
- Execute runbooks (automation documents)
- Multi-account, multi-region execution with targets
- Approval actions for human-in-the-loop workflows
- Integrations: EventBridge, Config remediation, Maintenance Windows

Parameter Store:
- Tiers: Standard (free, 10KB, 10000 params) vs Advanced (paid, 8KB, 100000 params, TTL/expiry)
- Types: String, StringList, SecureString (KMS encrypted)
- Hierarchy: `/app/prod/db/password` path structure
- Version tracking; reference specific version with `name:version`
- EventBridge events on parameter change

Secrets Manager vs Parameter Store:
- Secrets Manager: automatic rotation (Lambda-based), native integrations (RDS, Redshift, DocumentDB), higher cost
- Parameter Store: no native rotation, cheaper, good for non-secret config and secrets

Session Manager:
- Browser or CLI shell access to EC2 without SSH or bastion host
- No inbound ports needed; traffic via SSM endpoint
- Audit: session logs to S3 and/or CloudWatch Logs
- Required: SSM Agent, IAM role with `AmazonSSMManagedInstanceCore`

Patch Manager:
- Patch baselines: define approved/rejected patches by severity, classification, CVE
- Patch groups: tag instances with `Patch Group` key; associate baseline to group
- Maintenance Windows: schedule patching with defined duration and targets

Run Command:
- Execute commands on multiple instances without SSH
- Rate control: concurrency (% or count) and error threshold
- Output: console, S3, CloudWatch Logs

Inventory:
- Collect metadata: installed apps, network config, Windows updates, running services
- Query with Config or Athena

---

### OpsWorks

- Managed Chef (OpsWorks for Chef Automate) and Puppet (OpsWorks for Puppet Enterprise)
- OpsWorks Stacks: older service; layer-based model; Chef Solo cookbooks
- Layers: define resources and config for groups of instances
- Auto healing: replace failed instances automatically
- Lifecycle events per layer: Setup, Configure, Deploy, Undeploy, Shutdown
- CloudWatch Logs integration; CloudWatch metrics for instance monitoring

---

## 3. MONITORING AND LOGGING

### CloudWatch Metrics

- Namespaces: logical grouping (e.g., AWS/EC2, AWS/RDS)
- Dimensions: name-value pairs that identify a metric (e.g., InstanceId=i-1234)
- Standard resolution: 1-minute minimum
- High resolution: 1 second (custom metrics only, additional cost)
- Retention: 3h data at 1s, 15 days at 1m, 63 days at 5m, 15 months at 1h
- Statistics: Average, Sum, Minimum, Maximum, SampleCount, percentiles (p99, p99.9)
- Extended statistics: trimmed mean, winsorized mean, percentile rank

Custom metrics:
```bash
aws cloudwatch put-metric-data \
  --namespace MyApp \
  --metric-name OrdersProcessed \
  --value 42 \
  --unit Count \
  --dimensions Environment=prod,Service=order-processor
```

Metric math: combine metrics with math expressions in dashboards and alarms

---

### CloudWatch Alarms

- States: OK, ALARM, INSUFFICIENT_DATA
- Actions: SNS, EC2 actions (stop/terminate/reboot/recover), ASG scaling, Systems Manager OpsItem
- Evaluation: DatapointsToAlarm out of EvaluationPeriods (M of N)
- Treat missing data: missing (use period state), notBreaching, breaching, ignore
- Composite alarms: combine multiple alarms with AND/OR logic; reduces alarm noise
- Alarm on anomaly detection: ML-based baseline; alarm when metric outside band

---

### CloudWatch Logs

- Log groups: container for log streams; set retention (1 day to 10 years or never expire)
- Log streams: sequence of events from same source
- Metric filters: extract metric data from log events using filter patterns
- Subscription filters: stream logs to Lambda, Kinesis, Kinesis Data Firehose, OpenSearch
- Log Insights: query language for analyzing log data
- Contributor Insights: identify top contributors (e.g., top error-producing hosts)
- Live Tail: real-time streaming of log events in console

Exporting logs:
- S3 export: `create-export-task`; not real-time; up to 12h delay
- Subscription filter to Firehose: near-real-time delivery to S3, Redshift, OpenSearch

Cross-account log sharing:
- Subscription filter on source account destination in receiving account
- Destination policy grants source account PutSubscriptionFilter permission

---

### CloudWatch Agent

- Collect custom metrics from EC2 and on-premises (memory, disk, CPU detail)
- Collect logs from any file path
- Config stored in SSM Parameter Store for fleet distribution
- StatsD and collectd protocol support
- procstat plugin: per-process metrics (CPU, memory, file descriptors)

---

### CloudTrail

- Records API calls (management events by default; data events optional)
- Event types: Management events (control plane), Data events (S3 object level, Lambda invokes, DynamoDB item level), Insights events (unusual API call rate or error rate)
- Trail: deliver to S3; optionally to CloudWatch Logs, EventBridge
- Organization trail: single trail for all accounts in AWS Organization
- Global services: IAM, STS, CloudFront always log to us-east-1
- Log file integrity: SHA-256 digest files; verify with `validate-logs` command
- Encryption: S3 SSE-S3 by default; optionally SSE-KMS with CMK
- Event history: 90 days free in console; trails for longer retention
- Insights: detect anomalous write management API activity

---

### X-Ray

- Distributed tracing for applications
- Segments: work done by your application
- Subsegments: granular breakdown (downstream calls, SQL, AWS SDK calls)
- Traces: end-to-end request path; assembled from segments by X-Ray service
- Service map: visual representation of services and their connections
- Sampling: reduce volume; default 5% + 1 req/s; custom rules by host, method, URL, service
- Groups: filter traces by expression; create separate service maps
- Annotations: indexed key-value pairs; filterable in console
- Metadata: non-indexed key-value pairs; richer data storage

Instrumentation:
- X-Ray SDK: instrument AWS SDK calls, HTTP calls, SQL queries
- X-Ray daemon: receives UDP traffic on port 2000 from SDK; batches and sends to X-Ray service
- Lambda: built-in integration with Active tracing enabled; daemon included
- ECS: daemon as sidecar container or daemon task

Required IAM permissions:
- `xray:PutTraceSegments`, `xray:PutTelemetryRecords`, `xray:GetSamplingRules`

---

### EventBridge

- Serverless event bus; formerly CloudWatch Events
- Event buses: default (AWS services), custom, partner (SaaS)
- Rules: match events with patterns; route to targets
- Targets: Lambda, Step Functions, SNS, SQS, Kinesis, CodePipeline, EC2 Run Command, API Gateway, and more
- Archive: store events; replay for testing or recovery
- Schema registry: discover event schemas; generate code bindings
- Pipes: point-to-point integration with filtering and enrichment (source -> filter -> enrichment -> target)
- Scheduler: create scheduled events; one-time or recurring (cron/rate expressions)
- Cross-account: event bus resource policy allows other accounts to send events

---

### Amazon OpenSearch Service (for DevOps)

- Managed OpenSearch/Elasticsearch cluster
- Use case: log analytics, full-text search, operational dashboards
- Ingest: Kinesis Data Firehose, CloudWatch Logs subscription, Logstash, Fluent Bit
- Dashboards: Kibana/OpenSearch Dashboards for visualization
- Index State Management (ISM): automate index lifecycle (rollover, delete, snapshot)
- UltraWarm: S3-backed warm storage for infrequently accessed data; lower cost

---

### Kinesis

Kinesis Data Streams:
- Real-time streaming; millisecond latency
- Shards: 1MB/s write, 2MB/s read per shard
- Retention: 24h default; up to 365 days
- Enhanced fan-out: dedicated 2MB/s per consumer per shard; push model via HTTP/2
- Producers: SDK, KPL (aggregation + batching), Kinesis Agent
- Consumers: KCL (stateful; checkpoints in DynamoDB), Lambda, Kinesis Data Analytics, Firehose
- Ordering: within shard by sequence number; use partition key for related records to same shard

Kinesis Data Firehose:
- Serverless delivery to S3, Redshift, OpenSearch, Splunk, HTTP endpoints, Snowflake
- No shards; auto-scaling
- Buffering: size (1-128MB) and time (60-900s)
- Transformation: Lambda function for format conversion
- Format conversion: JSON to Parquet/ORC using Glue schema registry
- Not real-time: minimum 60s delivery latency

Kinesis Data Analytics (now Amazon Managed Service for Apache Flink):
- SQL or Apache Flink for stream processing
- Consumes from Kinesis Data Streams or MSK

---

### Managed Grafana and Prometheus

Amazon Managed Prometheus (AMP):
- Prometheus-compatible metrics storage
- Ingestion via remote_write from Prometheus or AWS Distro for OpenTelemetry (ADOT)
- Query with PromQL; integrates with Managed Grafana

Amazon Managed Grafana (AMG):
- Managed Grafana workspace; IAM or SAML authentication
- Data sources: AMP, CloudWatch, OpenSearch, Athena, X-Ray, Timestream, and more
- Good for Kubernetes observability alongside Container Insights

---

### Container Insights

- CloudWatch Container Insights for ECS, EKS, Kubernetes
- Collect metrics: CPU, memory, network, disk at cluster, node, pod, container level
- Enhanced observability for EKS: uses CloudWatch agent as DaemonSet; detailed pod and node metrics
- Logs: FluentBit or Fluentd DaemonSet routes container logs to CloudWatch Logs
- Performance dashboards auto-created in CloudWatch console

---

*End of Part 1*

