# Security Scanning Guide

## Overview
Security scanning is integrated into the CI/CD pipeline using Trivy.

## Trivy Configuration

Configuration file: `infrastructure/docker/trivy/trivy.yaml`

Scanned severities:
- CRITICAL
- HIGH
- MEDIUM

## Running Security Scans

### Local Scanning
```bash
# Scan Docker image
./scripts/security/trivy-scan.sh sample-app:latest

# Generate vulnerability report
./scripts/security/vulnerability-report.sh

# Check security gates
./scripts/security/security-gate.sh sample-app:latest
```

### Automated Scanning
Security scans run automatically:
- On every push to main branch
- Daily at 2 AM UTC
- Can be triggered manually

## Security Gates

Deployment blocked if:
- Any CRITICAL vulnerabilities found
- More than 5 HIGH vulnerabilities found

## Handling Vulnerabilities

1. Review scan results in `security-reports/`
2. Update base images to patched versions
3. Update dependencies: `npm audit fix`
4. Add exceptions to `.trivyignore` if needed (with justification)

## Reports

Reports are stored in:
- `security-reports/trivy-report-*.json` - Full JSON report
- `security-reports/trivy-summary-*.txt` - Human-readable summary

## Best Practices

1. Scan regularly (daily minimum)
2. Update base images frequently
3. Keep dependencies up to date
4. Review and act on scan results promptly
5. Document accepted risks in `.trivyignore`