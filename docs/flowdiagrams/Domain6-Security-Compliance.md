# Domain 6: Security and Compliance

> Flow and sequence diagrams covering IAM, KMS, Secrets Manager

---

## 1. IAM Policy Evaluation Logic

**Services Involved**: IAM, SCP, Resource Policy, Permission Boundary, Session Policy

```mermaid
flowchart TD
    Request[API Request] --> Deny1{Explicit Deny in any policy?}
    Deny1 -->|yes| Denied[DENY]
    Deny1 -->|no| SCP{SCP allows?}
    SCP -->|no| Denied
    SCP -->|yes| ResourcePolicy{Resource-based policy allows?}
    ResourcePolicy -->|yes| Allowed[ALLOW]
    ResourcePolicy -->|no| Boundary{Permission Boundary set?}
    Boundary -->|yes, does not allow| Denied
    Boundary -->|yes, allows| IdentityPolicy{Identity-based policy allows?}
    Boundary -->|no boundary| IdentityPolicy
    IdentityPolicy -->|yes| Allowed
    IdentityPolicy -->|no| Denied
```

---

## 2. IAM Roles — Cross-Account Access Flow

**Services Involved**: IAM, STS, S3, CloudTrail

```mermaid
sequenceDiagram
    participant DevAccount as Dev Account
    participant STS as AWS STS
    participant ProdAccount as Prod Account
    participant Resource as Prod Resource (S3 / RDS)

    DevAccount->>STS: AssumeRole (arn:aws:iam::PROD:role/CrossAccountRole)
    STS->>ProdAccount: Verify trust policy
    ProdAccount-->>STS: Trust policy allows Dev Account
    STS-->>DevAccount: Temporary credentials (AccessKey + SecretKey + Token)
    DevAccount->>Resource: API call with temporary credentials
    Resource->>Resource: Evaluate role permissions
    Resource-->>DevAccount: Response
```
---

## 3. Secrets Manager — Secret Rotation Flow

**Services Involved**: Secrets Manager, Lambda, RDS, KMS, CloudTrail

```mermaid
sequenceDiagram
    participant SM as Secrets Manager
    participant Lambda as Rotation Lambda
    participant DB as RDS Database
    participant App as Application

    SM->>Lambda: Invoke rotation (createSecret step)
    Lambda->>SM: Store new secret version (AWSPENDING)

    SM->>Lambda: Invoke rotation (setSecret step)
    Lambda->>DB: Update DB password to new value

    SM->>Lambda: Invoke rotation (testSecret step)
    Lambda->>DB: Test login with new credentials
    DB-->>Lambda: Login success

    SM->>Lambda: Invoke rotation (finishSecret step)
    Lambda->>SM: Move AWSPENDING to AWSCURRENT
    SM->>SM: Move AWSCURRENT to AWSPREVIOUS

    App->>SM: GetSecretValue
    SM-->>App: Return AWSCURRENT secret
```

---

