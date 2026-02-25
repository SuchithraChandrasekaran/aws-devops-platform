# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | Yes                |
| < 1.0   | No                 |

## Reporting a Vulnerability

Please report security vulnerabilities to: security@example.com

Do not open public issues for security vulnerabilities.

## Security Scanning

This project uses automated security scanning:

1. **Secret Detection**: TruffleHog and detect-secrets
2. **Dependency Scanning**: Safety and pip-audit
3. **Container Scanning**: Trivy
4. **SAST**: Bandit for Python code
5. **Infrastructure Scanning**: tfsec and Checkov for Terraform

## Security Best Practices

1. Never commit secrets or credentials
2. Keep dependencies updated
3. Use minimal base images
4. Run containers as non-root
5. Enable security scanning in CI/CD
6. Regular security audits
7. Follow least privilege principle

## Vulnerability Response

1. Critical vulnerabilities: Fixed within 24 hours
2. High vulnerabilities: Fixed within 1 week
3. Medium vulnerabilities: Fixed within 1 month
4. Low vulnerabilities: Fixed in next release

## Security Contacts

- Security Team: security@example.com
- DevSecOps Lead: devsecops@example.com
