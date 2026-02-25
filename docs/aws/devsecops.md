# DevSecOps - Security in CI/CD

### Security Scanning Tools

**1. Secret Detection**
- TruffleHog: Scans git history for secrets
- detect-secrets: Prevents secrets in commits
- Pre-commit hooks: Runs before code is committed

**2. Dependency Scanning**
- Safety: Python package vulnerabilities
- pip-audit: Alternative dependency scanner
- Checks against CVE database

**3. Container Scanning**
- Trivy: Container image vulnerabilities
- Scans OS and library packages
- SARIF output for GitHub Security

**4. SAST (Static Application Security Testing)**
- Bandit: Python code security issues
- Detects common security flaws
- Configurable rules

**5. Infrastructure Scanning**
- tfsec: Terraform security checks
- Checkov: Multi-cloud IaC scanner
- Detects misconfigurations

### GitHub Actions Workflow

**Pipeline Stages:**
1. Secret scanning on code commits
2. Dependency vulnerability check
3. Dockerfile security analysis
4. Container image scanning
5. Terraform security scan
6. Code quality and SAST

**Workflow Triggers:**
- Push to main/develop branches
- Pull requests to main
- Manual workflow dispatch

### Security Scan Results

**Severity Levels:**
- CRITICAL: Immediate action required
- HIGH: Fix within 1 week
- MEDIUM: Fix within 1 month
- LOW: Fix in next release

**Report Formats:**
- SARIF: GitHub Security integration
- JSON: Machine-readable
- Table: Human-readable console output

### Pre-commit Hooks

Runs before each commit:
1. Trailing whitespace check
2. YAML validation
3. Large file detection
4. Private key detection
5. AWS credentials detection
6. Secret scanning
7. Terraform security scan
8. Python SAST

### Best Practices

1. Shift security left (early in pipeline)
2. Fail builds on critical issues
3. Regular dependency updates
4. Minimal container base images
5. Non-root container users
6. Secrets in environment variables
7. Security policy documentation
8. Vulnerability response plan

### Common Vulnerabilities

**Dependencies:**
- Outdated packages with CVEs
- Known security flaws
- Unmaintained libraries

**Containers:**
- Vulnerable base images
- Exposed sensitive data
- Running as root user

**Code:**
- SQL injection
- Command injection
- Hardcoded secrets
- Insecure functions

**Infrastructure:**
- Open security groups
- Unencrypted storage
- Missing MFA
- Overly permissive IAM

### Remediation Steps

**For Dependencies:**
1. Update to patched version
2. Find alternative package
3. Apply vendor patch
4. Document exception if no fix

**For Containers:**
1. Update base image
2. Remove vulnerable packages
3. Use distroless images
4. Scan regularly

**For Code:**
1. Fix vulnerable code
2. Use safe functions
3. Input validation
4. Output encoding

**For Infrastructure:**
1. Apply security controls
2. Enable encryption
3. Restrict access
4. Add monitoring

### Integration with AWS

**Security Hub:**
- Centralized findings
- Multi-account aggregation
- Compliance standards

**CodeGuru:**
- AI-powered code review
- Security recommendations
- Performance insights

**ECR Scanning:**
- Automatic image scanning
- CVE database updates
- Scan on push

### Cost Considerations

**Free Tier:**
- GitHub Actions: 2000 minutes/month
- TruffleHog: Free
- Trivy: Free
- Safety: Free
- Bandit: Free
- tfsec: Free
