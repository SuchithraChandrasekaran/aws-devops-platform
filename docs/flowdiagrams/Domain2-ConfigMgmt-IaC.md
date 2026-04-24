
main 2: Configuration Management and IaC

> Flow and sequence diagrams covering CloudFormation, CDK, SSM, OpsWorks, and related IaC and configuration management services.

---

## 1. CloudFormation Stack Lifecycle

**Services Involved**: CloudFormation, S3, IAM, SNS

```mermaid
flowchart TD
    Template[CloudFormation Template\n.yaml / .json] -->|upload| S3[S3 Bucket]
    S3 -->|reference| CFN[CloudFormation]
    CFN --> Validate[Validate Template]
    Validate --> ChangeSet[Create Change Set]
    ChangeSet -->|review| Execute[Execute Change Set]
    Execute --> Create[CREATE_IN_PROGRESS]
    Create -->|success| Complete[CREATE_COMPLETE]
    Create -->|failure| Rollback[ROLLBACK_IN_PROGRESS]
    Rollback --> RollbackComplete[ROLLBACK_COMPLETE]
    Complete --> Update[Stack Update]
    Update --> UpdateChangeSet[Create Change Set]
    UpdateChangeSet -->|execute| UpdateComplete[UPDATE_COMPLETE]
    UpdateChangeSet -->|failure| UpdateRollback[UPDATE_ROLLBACK_COMPLETE]
```

---

## 2. CloudFormation Cross-Stack References

**Services Involved**: CloudFormation, SSM Parameter Store, S3

```mermaid
flowchart TD
    NetworkStack[Network Stack\nvpc.yaml] -->|Export: VpcId| Exports[CloudFormation Exports]
    NetworkStack -->|Export: SubnetIds| Exports
    Exports -->|ImportValue| AppStack[App Stack\napp.yaml]
    Exports -->|ImportValue| DBStack[DB Stack\nrds.yaml]

    AppStack -->|DependsOn export| NetworkStack
    DBStack -->|DependsOn export| NetworkStack

    Note[Cannot delete NetworkStack\nwhile exports are in use]
```

---

## 3. CloudFormation StackSets — Multi-Account / Multi-Region

**Services Involved**: CloudFormation StackSets, AWS Organizations, IAM

```mermaid
flowchart TD
    Admin[Admin Account\nStackSet Definition] -->|assume role| Target1[Target Account A\nAWSCloudFormationStackSetExecutionRole]
    Admin -->|assume role| Target2[Target Account B\nAWSCloudFormationStackSetExecutionRole]
    Admin -->|assume role| Target3[Target Account C\nAWSCloudFormationStackSetExecutionRole]

    Target1 -->|deploy stack| Region1[us-east-1]
    Target1 -->|deploy stack| Region2[ap-south-1]
    Target2 -->|deploy stack| Region1
    Target3 -->|deploy stack| Region2

    Org[AWS Organizations] -->|auto deploy| Admin
```

---

## 4. CloudFormation Custom Resource Flow

**Services Involved**: CloudFormation, Lambda, S3 (presigned URL), SNS

```mermaid
sequenceDiagram
    participant CFN as CloudFormation
    participant Lambda as Lambda Function
    participant Resource as External Resource
    participant S3 as S3 Pre-signed URL

    CFN->>Lambda: Invoke (Create / Update / Delete)
    Lambda->>Resource: Provision / Configure / Delete
    Resource-->>Lambda: Response
    Lambda->>S3: PUT response (SUCCESS / FAILED)
    S3-->>CFN: CloudFormation reads response
    CFN->>CFN: Continue stack operation
```

---

## 5. AWS CDK Synthesis and Deploy Flow

**Services Involved**: AWS CDK, CloudFormation, S3, ECR, IAM (CDK Toolkit)

```mermaid
flowchart LR
    Code[CDK App Code\nTypeScript / Python] -->|cdk synth| Template[CloudFormation Template]
    Template -->|cdk bootstrap| Bootstrap[CDKToolkit Stack\nS3 + ECR + IAM roles]
    Bootstrap -->|cdk deploy| CFN[CloudFormation]
    CFN -->|create / update| Stack[AWS Resources]

    Code -->|cdk diff| Diff[Show pending changes]
    Code -->|cdk destroy| Destroy[Delete Stack]
```

---

## 6. SSM Parameter Store vs Secrets Manager

**Services Involved**: SSM Parameter Store, Secrets Manager, KMS, Lambda, EC2

```mermaid
flowchart TD
    App[Application\nEC2 / Lambda / ECS] --> Choice{Credential Type}

    Choice -->|config values, non-sensitive| SSM[SSM Parameter Store\nStandard / Advanced tier]
    Choice -->|passwords, API keys, DB creds| SM[Secrets Manager]

    SSM -->|SecureString| KMS1[KMS Encryption]
    SM -->|automatic rotation| Lambda2[Rotation Lambda]
    Lambda2 -->|update secret| SM
    SM -->|encrypt| KMS2[KMS Encryption]

    SSM -->|reference in CFN| CFN[CloudFormation\ndynamic references]
    SM -->|reference in CFN| CFN
```

---

## 7. SSM State Manager — Configuration Compliance Flow

**Services Involved**: SSM State Manager, SSM Documents, EC2, S3, CloudWatch

```mermaid
flowchart TD
    Association[SSM Association\nDocument + Target + Schedule] -->|apply| Instances[EC2 Instances\nvia SSM Agent]
    Instances -->|execute| Document[SSM Document\nAWS-ApplyAnsiblePlaybooks\nAWS-RunShellScript etc]
    Document -->|report| Compliance[Compliance Status\nCOMPLIANT / NON_COMPLIANT]
    Compliance -->|non-compliant| CW[CloudWatch Alarm]
    CW -->|trigger| Remediation[EventBridge + Lambda\nAuto Remediation]
    Association -->|output logs| S3[S3 / CloudWatch Logs]
```

---

## 8. SSM Automation Runbook Flow

**Services Involved**: SSM Automation, IAM, EC2, Lambda, CloudWatch

```mermaid
sequenceDiagram
    participant Trigger as Trigger (EventBridge / Manual)
    participant SSM as SSM Automation
    participant IAM as IAM Assume Role
    participant Action as Automation Action
    participant Resource as AWS Resource

    Trigger->>SSM: Start Automation Execution
    SSM->>IAM: Assume AutomationServiceRole
    IAM-->>SSM: Temporary Credentials

    loop Each Step in Runbook
        SSM->>Action: Execute Step (aws:runCommand / aws:invokeLambdaFunction)
        Action->>Resource: Perform Action
        Resource-->>SSM: Step Result
    end

    SSM->>Trigger: Execution Complete (Success / Failed)
```

---

## 9. OpsWorks Stacks Layer Model

**Services Involved**: OpsWorks Stacks, EC2, RDS, ELB, Chef

```mermaid
flowchart TD
    Stack[OpsWorks Stack] --> LB[Load Balancer Layer\nELB]
    Stack --> App[App Server Layer\nEC2 + Chef Recipes]
    Stack --> DB[Database Layer\nRDS / MySQL]

    App -->|lifecycle events| Events[Chef Recipes]
    Events --> Setup[setup event\ninstall packages]
    Events --> Configure[configure event\nconfig files]
    Events --> Deploy[deploy event\ndeploy app]
    Events --> Undeploy[undeploy event]
    Events --> Shutdown[shutdown event]

    LB -->|routes to| App
    App -->|connects to| DB
```

---

## 10. Ansible vs SSM Run Command — Push vs Pull

**Services Involved**: Ansible, SSM Run Command, EC2, S3

```mermaid
flowchart TD
    Change[Configuration Change Required]

    Change --> Ansible[Ansible\nPush Model]
    Change --> SSM[SSM Run Command\nPull / API Model]

    Ansible -->|SSH / WinRM| Nodes[Target EC2 Instances]
    Ansible -->|reads| Inventory[Inventory File\nstatic or dynamic]
    Ansible -->|executes| Playbook[Playbook\n.yml tasks]

    SSM -->|no SSH required| Agent[SSM Agent on EC2]
    SSM -->|reads| Document[SSM Document\ncommands / scripts]
    SSM -->|output to| S3Log[S3 / CloudWatch Logs]
    Agent -->|execute| Nodes
```

---

## 11. CloudFormation Drift Detection Flow

**Services Involved**: CloudFormation, AWS Config, SNS, Lambda

```mermaid
flowchart TD
    Stack[CloudFormation Stack] -->|detect drift| Drift[Detect Stack Drift]
    Drift -->|per resource| DriftResult{Drift Status}

    DriftResult -->|MODIFIED| Modified[Resource config changed\noutside CloudFormation]
    DriftResult -->|DELETED| Deleted[Resource deleted\noutside CloudFormation]
    DriftResult -->|IN_SYNC| InSync[No drift detected]

    Modified -->|remediate| Options{Remediation Options}
    Options -->|option 1| Import[CloudFormation Import Resource]
    Options -->|option 2| Redeploy[Re-deploy Stack\noverwrite manual changes]

    Config[AWS Config Rule\ncloudformation-stack-drift-detection] -->|trigger| Drift
    Drift -->|notify| SNS[SNS Alert]
```

---

## 12. Service Catalog — Governed IaC Provisioning

**Services Involved**: Service Catalog, CloudFormation, IAM, S3

```mermaid
sequenceDiagram
    participant Admin as Cloud Admin
    participant SC as Service Catalog
    participant CFN as CloudFormation
    participant EndUser as End User (Dev Team)
    participant Resource as AWS Resources

    Admin->>SC: Create Portfolio
    Admin->>SC: Add Product (CFN Template)
    Admin->>SC: Set Launch Constraints (IAM Role)
    Admin->>SC: Grant access to End User

    EndUser->>SC: Browse Portfolio
    EndUser->>SC: Launch Product
    SC->>CFN: Deploy Template (using Launch Role)
    CFN->>Resource: Provision Resources
    Resource-->>EndUser: Stack Output (endpoint, ARN etc)
```
