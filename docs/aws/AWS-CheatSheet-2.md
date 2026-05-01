# AWS DevOps Engineer Professional - Cheat Sheet Part 2

## Domains Covered in Part 2
- Incident and Event Response
- High Availability, Fault Tolerance, and Disaster Recovery
- Security, Governance, and Compliance
- Supporting Services Quick Reference

---

## 4. INCIDENT AND EVENT RESPONSE

### Auto Scaling (EC2)

Scaling policies:
- Target tracking: maintain metric at target value (e.g., CPU at 50%); AWS manages scale-out and scale-in
- Step scaling: scale by fixed amount or percentage based on alarm breach magnitude; faster than target tracking
- Simple scaling: one adjustment per alarm; cooldown period before next action (legacy)
- Scheduled scaling: cron or one-time; predictable load patterns
- Predictive scaling: ML-based; forecasts load; scales ahead of time; needs at least 24h of data

Cooldown period:
- Default: 300 seconds; prevents rapid consecutive scaling
- Warm-up: time to wait before instance contributes to metrics (for step and target tracking)
- Instance refresh: rolling replacement of instances; configure min healthy percentage and warm-up

Termination policies:
- Default: oldest launch template/config first, then closest to billing hour
- OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, AllocationStrategy

Lifecycle hooks:
- Pending:Wait / Pending:Proceed: run actions before instance enters InService
- Terminating:Wait / Terminating:Proceed: run actions before instance is terminated
- Used for: install software, drain connections, register with CM tool, run tests
- Notification: EventBridge, SNS, SQS; heartbeat timeout default 1h

Health checks:
- EC2 health check: instance status check; ASG replaces on fail
- ELB health check: must enable; ASG replaces if ELB marks unhealthy
- Custom health check: mark instance unhealthy via API `set-instance-health`

Warm pools:
- Pre-initialized stopped or running instances
- Reduces time to scale out; instances skip initialization
- State: Stopped (cheapest), Running, Hibernated

---

### Elastic Load Balancing

ALB (Application Load Balancer):
- Layer 7; HTTP/HTTPS/WebSocket/HTTP2
- Target types: instance, IP, Lambda
- Rules: path-based, host-based, header-based, query-string, source IP routing
- Sticky sessions: application (cookie) or duration-based (LB cookie)
- Authentication: Cognito or OIDC IdP built in (AUTHENTICATE_COGNITO, AUTHENTICATE_OIDC actions)
- Weighted target groups: A/B testing or blue/green
- gRPC support
- Access logs to S3; processed by Athena or tools

NLB (Network Load Balancer):
- Layer 4; TCP/UDP/TLS
- Preserves source IP by default
- Zonal isolation: can disable cross-zone load balancing per target group
- Static IP per AZ; Elastic IP attachment
- Ultra-low latency; millions of requests per second
- PrivateLink endpoint service: expose service to other VPCs/accounts via NLB

CLB (Classic): legacy; avoid on exam unless specifically asked

Cross-zone load balancing:
- ALB: enabled by default (no charge)
- NLB/GWLB: disabled by default; charge applies when enabled

Deregistration delay (connection draining):
- Time ELB waits for in-flight requests to complete before deregistering target
- Default 300s; set to low value (e.g., 30s) for fast deployments

---

### Route 53

Routing policies:
- Simple: single resource; no health checks (unless alias)
- Weighted: A/B testing; weight 0 stops traffic to record
- Latency: route to region with lowest latency to user
- Failover: primary/secondary; active-passive; health check on primary
- Geolocation: based on user geography; must have default record
- Geoproximity (Traffic Flow only): bias value shifts boundary; positive attracts more traffic
- Multivalue answer: up to 8 healthy records returned; like simple with health checks
- IP-based: route based on user IP CIDR

Health checks:
- Endpoint checks: HTTP/HTTPS/TCP; string matching in response
- Calculated health checks: combine child health checks with AND/OR/NOT logic
- CloudWatch alarm health checks: healthy if alarm is OK; works for private resources
- Health check interval: 30s default; 10s fast (higher cost)
- Failure threshold: 3 consecutive failures

Private hosted zones: associated with VPCs; not publicly resolvable
Route 53 Resolver: hybrid DNS; inbound/outbound endpoints for on-premises integration
Resolver rules: forward specific domains to on-prem DNS

---

### SQS (High Availability and Decoupling)

- Standard: at-least-once delivery; best-effort ordering; nearly unlimited throughput
- FIFO: exactly-once processing; strict ordering; 300 TPS (3000 with batching)
- Visibility timeout: time message hidden after received; default 30s; max 12h; extend with `ChangeMessageVisibility`
- Message retention: 1 minute to 14 days; default 4 days
- Max message size: 256KB; use extended client with S3 for larger
- Long polling: WaitTimeSeconds up to 20s; reduces empty responses and cost
- Dead-letter queue: after maxReceiveCount failed processing attempts; same type (FIFO DLQ for FIFO)
- Delay queue: DelaySeconds 0-900; postpone initial visibility
- Server-side encryption: SSE-SQS (free) or SSE-KMS (per-request cost)

Lambda trigger from SQS:
- Lambda polls SQS (not SQS pushing)
- Batch size: 1-10000; batch window: 0-300s for accumulation
- On failure: entire batch returned to queue or sent to DLQ
- FIFO: Lambda scales up to number of MessageGroupIds; one concurrent invocation per group

---

### SNS (Notifications and Fan-out)

- Publishers send to topic; topic fans out to subscriptions
- Subscribers: SQS, Lambda, HTTP/S, Email, SMS, Kinesis Firehose, mobile push
- Fan-out pattern: SNS -> multiple SQS queues for parallel processing
- Message filtering: subscription filter policy (JSON) on message attributes
- FIFO topics: ordering and deduplication; only SQS FIFO as subscriber
- Message archival: not built-in; use SQS or Firehose subscriber
- DLQ: per subscription; after delivery failure retries exhausted
- SSE: optional; SSE-KMS
- Cross-region delivery to SQS: supported

---

### Step Functions

- Orchestrate Lambda, ECS, DynamoDB, SQS, SNS, Glue, SageMaker, and more
- Standard workflows: at-most-once; up to 1 year; auditable history; async
- Express workflows: at-least-once; up to 5 minutes; high throughput; sync or async
- States: Task, Choice, Wait, Parallel, Map, Pass, Succeed, Fail
- Error handling: `Catch` (transition to error state), `Retry` (exponential backoff)
- Callback pattern: task sends token to external system; external system calls `SendTaskSuccess/Failure`
- Activity tasks: worker polls for tasks (pull model vs push for Lambda)
- Map state: process array items in parallel (mode: INLINE) or with concurrency control
- Distributed Map: process S3 objects or large arrays; up to 10000 concurrent iterations

---

### Lambda (Operational Aspects)

Concurrency:
- Account default: 1000 concurrent executions per region
- Reserved concurrency: cap a function; guarantees quota for that function
- Provisioned concurrency: pre-initialized instances; no cold starts; cost per second
- Burst limits: 500-3000 initial burst depending on region; then +500/minute

Versions and aliases:
- Version: immutable snapshot of code and config
- Alias: mutable pointer to version; can split traffic (weighted alias)
- CodeDeploy + Lambda: shift traffic from old to new version; use alias

Destinations:
- On success: SQS, SNS, EventBridge, Lambda
- On failure: SQS, SNS, EventBridge, Lambda
- For async invocations; more flexible than DLQ

Layers:
- Reusable code and dependencies packaged separately
- Up to 5 layers per function; total unzipped size 250MB
- Layer versions: immutable; functions reference specific layer version ARN

Lambda with VPC:
- ENI created in function's subnet; uses Hyperplane ENI (shared)
- Needs NAT Gateway or VPC endpoint for internet or AWS service access
- Cold start higher in VPC but improved with Hyperplane

SnapStart (Java):
- Take snapshot after init; restore from snapshot on invocation
- Reduces cold start for Java functions significantly

Function URLs:
- Built-in HTTPS endpoint for Lambda; no API Gateway needed
- Auth: AWS_IAM or NONE (public)

---

### CloudWatch Synthetics

- Canary scripts (Node.js or Python) that simulate user interactions
- Test API endpoints and URLs; record HAR files, screenshots
- Runs on schedule; alarms on failure
- Blueprints: heartbeat, API canary, broken link checker, visual monitoring, GUI workflow

---

### AWS Health

- AWS Health Dashboard (personal): events affecting your account resources
- EventBridge integration: `aws.health` events; automate remediation
- AWS Health API: programmatic access to events
- Organization-level view: aggregate health events across all accounts

EventBridge pattern for health event:

---

## 5. HIGH AVAILABILITY, FAULT TOLERANCE, AND DISASTER RECOVERY

### DR Strategies (RTO/RPO)

Backup and restore:
- Highest RTO/RPO; lowest cost
- Take backups to S3; restore on disaster
- RTO: hours; RPO: hours

Pilot light:
- Core infrastructure always running; scale out on disaster
- RTO: minutes to hours; RPO: minutes

Warm standby:
- Scaled-down replica always running; scale up on disaster
- RTO: minutes; RPO: seconds to minutes

Multi-site active-active:
- Lowest RTO/RPO; highest cost
- All sites handling traffic simultaneously
- RTO: near zero; RPO: near zero

---

### RDS High Availability

Multi-AZ:
- Synchronous replication to standby in different AZ
- Automatic failover; DNS updated; typically 60-120 seconds
- Standby not readable; use Read Replicas for read scaling
- Multi-AZ DB Cluster: 2 readable standby instances; 3 AZ; lower write latency

Read Replicas:
- Asynchronous replication; readable; up to 15 for Aurora, 5 for RDS
- Promote to standalone DB; used in DR (different region replica)
- Cross-region replication for global read scaling and DR

Backup:
- Automated: daily snapshot + transaction logs; PITR up to 35 days
- Manual snapshots: indefinitely retained; copy to another region for DR
- Restore creates new DB instance; update app connection string

RDS Proxy:
- Pooling connections; reduces failover time to seconds
- Serverless apps with Lambda; preserves connections during failover
- Integrates with Secrets Manager for credential rotation

---

### Aurora

- Writer + up to 15 reader instances sharing storage
- Storage: auto-grows 10GB to 128TB; 6 copies across 3 AZ; tolerates 2 copy write failure, 3 copy read failure
- Failover: replica promoted in under 30 seconds; or Aurora creates new instance in under 15 minutes
- Aurora Serverless v2: instant scaling; no capacity planning; charge per ACU-second
- Global database: primary region + up to 5 secondary; replication lag under 1 second; failover RPO seconds
- Backtrack: rewind DB without restore (MySQL only); up to 72 hours
- Clone: fast database copy using copy-on-write; no data transfer cost

---

### DynamoDB HA and DR

- Multi-AZ by default; data replicated across 3 AZ
- Global Tables: multi-region, multi-active; last-writer-wins conflict resolution
- Point-in-time recovery (PITR): continuous backups; restore to any point in 35 days
- On-demand backup: full table backup; no performance impact; restore to same or different region
- DynamoDB Streams + Lambda: capture changes; replicate to other systems

---

### S3 Durability and Availability

- 11 nines durability; 4 nines availability (standard)
- Storage classes: Standard, Standard-IA, Intelligent-Tiering, One Zone-IA, Glacier Instant, Glacier Flexible, Glacier Deep Archive
- Replication: CRR (cross-region) and SRR (same-region); requires versioning; can replicate delete markers
- Object Lock: WORM; governance or compliance mode; retain until date or legal hold
- MFA Delete: requires MFA for permanent object deletion
- Versioning: protect against accidental deletion and overwrites
- Lifecycle rules: transition and expiration based on object age or prefix

---

### Elastic Disaster Recovery (DRS)

- Continuous block-level replication to AWS from on-prem or other cloud
- Replication agent on source server; data staged in low-cost S3
- Recovery: launch recovery instances; point-in-time recovery
- Failback: replicate back to original environment after recovery
- RPO: seconds; RTO: minutes

---

### Backup

- AWS Backup: centralized backup across services (EC2, EBS, RDS, Aurora, DynamoDB, EFS, FSx, S3, VMware)
- Backup plans: schedule, lifecycle (cold storage transition, retention)
- Backup vault: encrypted storage for recovery points; vault lock (WORM compliance)
- Cross-account backup: with AWS Organizations; policy-based
- Cross-region backup: copy recovery points to another region

---

## 6. SECURITY, GOVERNANCE, AND COMPLIANCE

### IAM Deep Dive

Evaluation logic (in order):
1. Explicit deny in any policy -> DENY
2. Organizations SCP restricts -> DENY (if no allow in SCP)
3. Resource-based policy allows (same account) -> ALLOW without identity-based policy
4. Identity-based policy allows -> ALLOW (if no explicit deny)
5. IAM permission boundary restricts -> DENY
6. Session policy restricts -> DENY

Policies types:
- Identity-based: attached to user/group/role
- Resource-based: attached to resource (S3 bucket policy, KMS key policy, Lambda resource policy)
- Permission boundary: maximum permissions an IAM entity can have; does not grant permissions
- SCP (Service Control Policy): org-wide; max permissions for member accounts
- Session policy: passed during AssumeRole; further restrict session permissions
- ACL: cross-account access for S3 and VPC (legacy)

Roles:
- Trust policy: who can assume the role (Principal element)
- Permission policy: what the role can do
- AssumeRole: STS returns temp credentials (access key, secret key, session token)
- Role chaining: assume role, then assume another role; session limited to 1h
- Cross-account: role in account B; trust policy allows account A principal; account A policy allows sts:AssumeRole

Service-linked roles:
- Pre-defined by AWS service; cannot modify trust policy
- Created automatically when you use the service
- `AWSServiceRoleFor*` naming convention

ABAC (Attribute-Based Access Control):
- Tags on both IAM principals and resources control access
- Condition: `StringEquals: aws:PrincipalTag/team: $aws:ResourceTag/team`
- Scale access control without managing individual policies per resource

---

### KMS

Key types:
- AWS managed keys (aws/service): free; auto-rotated every year; no management
- Customer managed keys (CMK): paid; control rotation, deletion, key policy; 90-day to 7-year rotation
- Customer provided keys (SSE-C): S3 only; customer manages outside AWS

Key policies:
- Root account must have access (default key policy grants this)
- Key policy is required even for IAM policies to work (unlike S3 bucket policies)
- Grants: temporary delegated access; used by AWS services on your behalf

Encryption context:
- Arbitrary key-value pairs bound to encryption operation
- Must provide same context for decryption
- Included in CloudTrail logs

Cross-account KMS:
- Key policy allows external account principal
- External account IAM policy allows kms:Decrypt etc.

CMK deletion: 7-30 day waiting period; schedule and cancel; not reversible after period

Multi-region keys:
- Primary key replicated to other regions; same key material
- Client-side encryption use case: encrypt in one region, decrypt in another without re-encryption

---

### Secrets Manager

- Store and rotate credentials, API keys, certificates
- Native rotation for: RDS, Redshift, DocumentDB, other DBs with Lambda
- Rotation Lambda: single user or alternating users strategy
- Versioning: AWSCURRENT, AWSPENDING, AWSPREVIOUS staging labels
- Cross-account: resource-based policy + KMS key policy
- VPC endpoint (PrivateLink) for private access without internet
- Replicate secret to other regions; read-only replicas

---

### AWS Organizations

- Management account: pays for all; not governed by SCPs
- Member accounts: governed by SCPs; cannot leave org unilaterally
- OU (Organizational Unit): group accounts; hierarchical; SCPs inherited
- SCP: inheritance is AND; root -> OU -> account; child SCP cannot grant what parent denies
- Delegated administrators: assign service management to member accounts
- Service integrations: Config, Security Hub, GuardDuty, Firewall Manager, RAM, etc.

SCP effective permissions:
- Intersection of SCP and IAM permissions
- SCP does not apply to management account
- Deny list strategy (default): FullAWSAccess SCP + explicit denies
- Allow list strategy: remove FullAWSAccess; add only what's allowed

---

### Security Hub

- Aggregated security findings from: GuardDuty, Inspector, Macie, IAM Access Analyzer, Firewall Manager, partner tools
- Standards: AWS Foundational Security Best Practices, CIS AWS Foundations, PCI DSS, NIST
- Controls: individual checks; each has status (PASSED, FAILED, NOT_AVAILABLE, WARNING)
- Findings: normalized to ASFF (AWS Security Finding Format)
- Cross-account: designate aggregation account; delegate from management account
- Automated response: EventBridge rule on finding; trigger Lambda or Step Functions for remediation

---

### GuardDuty

- Threat detection using ML, anomaly detection, integrated threat intelligence
- Data sources: VPC Flow Logs, CloudTrail management events, DNS logs, S3 data events (optional), EKS audit logs, Lambda network logs, RDS login events, EBS malware scanning (on-demand or GuardDuty-initiated)
- Finding types categories: Backdoor, Behavior, CryptoCurrency, DefenseEvasion, Discovery, Exfiltration, Impact, InitialAccess, Persistence, PrivilegeEscalation, Recon, ResourceConsumption, Stealth, Trojan, Unauthorized
- Severity: LOW (0.1-3.9), MEDIUM (4.0-6.9), HIGH (7.0-8.9)
- Multi-account: designate administrator account; member accounts send findings
- Suppression rules: suppress known benign findings
- EventBridge integration: trigger Lambda for automated remediation on finding

---

### Inspector

- Vulnerability assessment for EC2, Lambda, container images in ECR
- Continuous scanning (not point-in-time like legacy Inspector)
- EC2: OS vulnerabilities (CVEs), network reachability findings
- Lambda: application code vulnerabilities in function packages
- ECR: scan on push or continuously
- Findings go to Security Hub; EventBridge events
- Risk score: contextualized severity based on exploitability and network exposure

---

### Macie

- Sensitive data discovery in S3 using ML
- Managed data identifiers: credit cards, PII, credentials, etc.
- Custom data identifiers: regex with keywords
- Findings: policy findings (S3 bucket config issues), sensitive data findings
- Classification jobs: one-time or scheduled; define buckets and sampling depth
- Integration: Security Hub, EventBridge, Organizations

---

### IAM Access Analyzer

- Identify resources accessible from outside account or zone of trust (org or account)
- Resource types: S3, IAM roles, KMS, Lambda, SQS, Secrets Manager, SNS
- Zone of trust: account or organization
- Policy validation: check policies for errors, security warnings, suggestions
- Policy generation: generate IAM policy from CloudTrail events (least privilege)
- External access findings: resource shared with external principal
- Unused access findings: analyze roles and users for unused permissions/access

---

### WAF and Shield

WAF (Web Application Firewall):
- Attach to ALB, API Gateway, CloudFront, AppSync, Cognito User Pool, App Runner
- Web ACL: contains rules; rules have statement + action (Allow/Block/Count/CAPTCHA/Challenge)
- Rule groups: reusable; AWS Managed Rule Groups or custom
- Rate limiting: count requests per IP per time window; block/challenge excess
- Bot Control: managed rule group; detect and block bots; CAPTCHA/Challenge integration
- Fraud Control: account takeover protection, account creation fraud prevention

Shield:
- Standard: free; always on; DDoS protection for L3/L4 (SYN flood, UDP reflection)
- Advanced: paid; L7 protection; DRT (DDoS Response Team) access; cost protection; real-time metrics; proactive engagement

---

### VPC Security

Security Groups vs NACLs:
- SG: stateful; instance level; allow rules only; all rules evaluated
- NACL: stateless; subnet level; allow and deny; rules evaluated in order (lowest first); return traffic must be explicitly allowed

VPC Flow Logs:
- Capture metadata (not payload) for ENI, subnet, or VPC
- Destinations: CloudWatch Logs, S3, Kinesis Data Firehose
- Format: default or custom; includes srcaddr, dstaddr, srcport, dstport, protocol, action, log-status
- Use Athena for querying S3-stored flow logs

PrivateLink (VPC Endpoints):
- Interface endpoints: ENI in subnet; powered by PrivateLink; for AWS services and partner services
- Gateway endpoints: route table entry; S3 and DynamoDB only; free
- Endpoint policies: resource-based; restrict which resources can be accessed through endpoint

---

### Certificate Manager (ACM)

- Provision, manage, renew TLS certificates
- Public certificates: free; auto-renewed before expiry; must be in us-east-1 for CloudFront
- Private certificates: ACM Private CA; cost per CA and per certificate
- Import certificates: bring your own; not auto-renewed
- Certificate transparency logging: required for public certs; cannot disable
- Validation: DNS (recommended; CNAME record; auto-renewed as long as record exists) or email

---

### Cognito

User Pools:
- User directory; sign-up, sign-in, MFA
- Social identity providers: Google, Facebook, Amazon, Apple
- Triggers: Lambda at various auth lifecycle events (pre-signup, post-confirmation, pre-token-generation, etc.)
- JWT tokens: ID token, access token, refresh token
- Hosted UI: pre-built auth UI pages

Identity Pools (Federated Identity):
- Exchange tokens (from User Pool, social IdP, SAML, custom) for temporary AWS credentials
- IAM roles: authenticated and unauthenticated role
- Enhanced flow: GetId + GetCredentialsForIdentity (returns credentials directly)

---

### AWS Audit Manager

- Continuously collect evidence for compliance audits
- Frameworks: PCI DSS, HIPAA, SOC 2, GDPR, FedRAMP, CIS
- Custom frameworks: define controls and evidence sources
- Evidence types: Config evaluation results, CloudTrail events, Security Hub findings, custom evidence
- Assessment reports: auto-generated for auditors

---

## 7. SUPPORTING SERVICES QUICK REFERENCE

### CloudFront (DevOps Aspects)

- Invalidations: invalidate specific paths; first 1000 paths/month free; use versioned file names instead
- Origin failover: primary and secondary origin group; failover on 4xx/5xx
- Cache policies: separate cache key settings from origin request settings
- Cache key: default (Host header + URL); customize with headers, cookies, query strings
- Lambda@Edge: run Lambda at edge (viewer request/response, origin request/response); Node.js or Python; us-east-1 only
- CloudFront Functions: lightweight JS; viewer request/response only; microsecond latency; cheaper
- Signed URLs and signed cookies: restrict access to content; OAC (Origin Access Control) for S3
- Realtime logs: Kinesis Data Streams; access logs to S3

---

### API Gateway

- REST API, HTTP API, WebSocket API
- HTTP API: lower cost; faster; subset of REST features; good for Lambda and HTTP backends
- REST API: full features; caching; WAF; usage plans; API keys; request/response transformation
- Stage variables: config values per stage; reference as `${stageVariables.varName}`
- Canary deployments: send % of traffic to canary stage; promote or rollback
- Throttling: account limit 10000 RPS; method/stage limits; 429 on throttle
- Usage plans + API keys: meter API usage; throttle and quota per plan
- Caching: TTL 0-3600s; encryption optional; flush cache per stage or invalidate per request
- Integration types: Lambda (proxy or custom), HTTP (proxy or custom), AWS service, Mock
- VPC Link: connect API Gateway to private resources in VPC via NLB

---

### EKS (DevOps Considerations)

- Managed Kubernetes control plane; runs worker nodes on EC2 or Fargate
- Node groups: managed (auto-updated AMI) or self-managed
- Fargate profiles: serverless pods; no node management; limited features (no DaemonSets)
- IRSA (IAM Roles for Service Accounts): associate IAM role with K8s service account; OIDC integration
- Cluster autoscaler: Kubernetes Cluster Autoscaler or Karpenter (preferred); Karpenter provisions nodes faster, more flexibly
- EKS Add-ons: VPC CNI, CoreDNS, kube-proxy, EBS CSI driver, EFS CSI driver
- Container Insights: CloudWatch agent as DaemonSet; metrics and logs
- ECR authentication: `aws ecr get-login-password | docker login`; refreshed via instance profile or IRSA
- GitOps: ArgoCD or Flux on EKS; reconcile cluster state from Git

---

### Fargate

- Serverless compute for ECS and EKS
- ECS task sizing: CPU (256-16384 units) and memory (512MB-120GB); compatible combinations only
- No host access; no DaemonSets on ECS Fargate
- Logging: awslogs (CloudWatch), splunk, firelens (Fluentbit/Fluentd sidecar)
- Storage: 20GB ephemeral by default; up to 200GB configurable; EFS for persistent shared storage
- Security: task IAM role; execution role for ECR pull and Secrets Manager access

---

### Service Catalog

- Portfolio of approved CloudFormation products
- Admin creates products (CF templates); shares portfolios with accounts/OUs
- End users launch approved products without needing IAM permissions for underlying resources (launch constraint role)
- Constraints: launch (IAM role), notification (SNS), tag (enforce tags), template (CLI/console allow list)
- Self-service portal for governed infrastructure provisioning
- Integrates with Config for drift detection on provisioned products

---

### Trusted Advisor

- Best practice checks: cost, performance, security, fault tolerance, service limits, operational excellence
- Core checks: free for all; full access requires Business or Enterprise Support plan
- Categories:
  - Security: S3 public buckets, security group open ports, root MFA, IAM use
  - Fault Tolerance: EBS snapshots, RDS multi-AZ, Route 53 health checks
  - Cost: idle load balancers, underutilized EC2, unassociated Elastic IPs
  - Service Limits: utilization vs limits; near-limit warnings
- EventBridge integration: automate response to limit warnings
- Organizational view: aggregate checks across org accounts

---

### Cost Management (DevOps Relevance)

Cost Allocation Tags:
- Activate in Billing console; appear in Cost Explorer after 24h
- AWS generated (aws:) and user-defined; use for per-project/team cost tracking

Budgets:
- Alert when cost/usage/savings/RI coverage exceeds threshold
- Budget actions: apply SCP, IAM policy, or target instances on threshold breach

Cost Anomaly Detection:
- ML-based; detect unusual spend; alert via SNS

---

### Networking Services (Quick Reference)

Transit Gateway:
- Hub for VPC-to-VPC and VPN/Direct Connect connectivity
- Attach VPCs, VPN, Direct Connect gateways; route tables control traffic
- Inter-region peering: connect TGWs across regions
- Multicast support

Direct Connect:
- Dedicated private connection from on-prem to AWS
- Virtual interfaces: private VIF (VPC), public VIF (AWS public services), transit VIF (TGW)
- Speeds: 1Gbps, 10Gbps, 100Gbps dedicated; hosted: sub-1Gbps to 10Gbps
- Resiliency: order multiple connections; Active/Active or Active/Passive with BGP

Site-to-Site VPN:
- IPsec VPN over internet; 1.25 Gbps per tunnel; two tunnels per connection for HA
- Customer gateway device on-prem; Virtual Private Gateway or Transit Gateway on AWS

---

### Migration Services (Awareness)

- AWS Migration Hub: track migration projects; centralized dashboard
- Application Migration Service (MGN): lift-and-shift; continuous replication; minimal downtime
- Database Migration Service (DMS): migrate databases; homogeneous and heterogeneous; Schema Conversion Tool for heterogeneous
- DataSync: transfer data from on-prem NFS/SMB/HDFS to S3/EFS/FSx; automated, scheduled, incremental

---

## KEY NOTES

Deployment strategy selection:
- Zero downtime required + safe rollback: Blue/Green or Immutable
- Minimize cost during deployment: Rolling
- Fastest deployment regardless of downtime: All at once
- Lambda traffic shift: CodeDeploy with Canary or Linear
- ECS zero downtime: CodeDeploy Blue/Green with ALB

CloudFormation vs Beanstalk:
- Need full control of resources: CloudFormation
- Want platform-managed environment: Elastic Beanstalk (uses CloudFormation under the hood)
- Both support rolling updates; EB hides complexity

CI/CD pipeline triggers:
- Code push: CodeCommit trigger or EventBridge rule
- Docker image push to ECR: EventBridge rule on image action
- Scheduled: EventBridge Scheduler

Encryption at rest:
- EBS: AES-256 via KMS; encrypted AMI shares encrypted snapshots
- S3: SSE-S3, SSE-KMS, SSE-C, or CSE; bucket default encryption
- RDS: enable at creation; encrypted snapshots; cannot encrypt unencrypted DB in place (snapshot + copy + restore)
- DynamoDB: always encrypted; use CMK for customer control

Monitoring quick decisions:
- Real-time application tracing: X-Ray
- Log analysis and querying: CloudWatch Logs Insights
- Infrastructure metrics: CloudWatch Metrics + Dashboards
- Security posture: Security Hub + Config
- Unusual API activity: CloudTrail + GuardDuty
- Sensitive data in S3: Macie
- Vulnerability scanning: Inspector
- Operational events across accounts: AWS Health + EventBridge

Scaling triggers:
- CPU/memory: target tracking or step scaling
- SQS queue depth: target tracking (ApproximateNumberOfMessagesVisible) or step scaling
- Custom metric: publish to CloudWatch; alarm-based step scaling
- Schedule: scheduled action or Predictive Scaling

IAM quick decisions:
- Block action org-wide: SCP
- Restrict what a role can do regardless of identity policy: Permission Boundary
- Cross-account resource access: resource-based policy + identity-based policy in calling account
- Temporary elevated access: IAM role with AssumeRole; no need to share long-term credentials

High availability patterns:
- Stateless app + ALB: Multi-AZ ASG + ALB
- Stateful app: ElastiCache (session), DynamoDB (state), EFS (shared files)
- Database: Multi-AZ RDS or Aurora; read replicas for read scaling
- Global users: CloudFront + Route 53 latency routing + multi-region

---

*End of Part 2*

