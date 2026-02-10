# Parameter Store vs Secrets Manager

## Quick Comparison

| Feature | Parameter Store | Secrets Manager |
|---------|----------------|-----------------|
| Purpose | Configuration management | Secret rotation |
| Cost | Free (Standard) | $0.40/secret/month |
| Rotation | Manual | Automatic |
| Size Limit | 4KB / 8KB | 64KB |
| Encryption | Optional | Always |

## When to Use Parameter Store

- Application configuration
- Environment variables
- Feature flags
- Non-sensitive settings
- Cost-sensitive scenarios

## When to Use Secrets Manager

- Database credentials with rotation
- API keys requiring rotation
- Multi-region deployments
- Compliance requirements

## Recommendation

Start with Parameter Store for configuration.
Use Secrets Manager when you need automatic rotation.
