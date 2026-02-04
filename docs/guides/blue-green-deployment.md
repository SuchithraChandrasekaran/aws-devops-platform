# Blue-Green Deployment Guide
## Zero-Downtime Deployment Strategy

---

## What is Blue-Green Deployment?

Blue-green deployment is a release strategy that reduces downtime and risk by running two identical production environments called Blue and Green.

**Key Concept:** Only one environment (Blue or Green) serves production traffic at any time.

---

## How It Works

1. Blue environment serves all production traffic
2. Deploy new version to Green environment
3. Test Green environment thoroughly
4. Switch traffic from Blue to Green
5. Blue environment becomes standby for next deployment

---

## Benefits

1. Zero-downtime deployments
2. Instant rollback capability
3. Full testing in production-like environment
4. Reduced deployment risk
5. Easy disaster recovery

---

## Implementation in This Project

### Components

1. **Two Application Containers**
   - sample-app-blue (port 3000)
   - sample-app-green (port 3001)

2. **NGINX Load Balancer**
   - Routes traffic to active environment
   - Port 8080

3. **Configuration**
   - blue-green-config.json
   - Tracks active environment

### Deployment Process
```bash
# 1. Deploy new version
./scripts/deployment/blue-green-deploy.sh

# 2. Verify deployment
curl http://localhost:8080/health

# 3. If issues, rollback
./scripts/deployment/rollback.sh

# 4. Cleanup old version
./scripts/deployment/cleanup-old-version.sh
```

---

## Health Check Process

1. Container starts
2. Health check script runs every 5 seconds
3. Maximum 30 attempts (2.5 minutes)
4. Checks HTTP 200 response
5. Verifies response body contains "healthy"

---

## Rollback Procedure

Rollback is instant because the old environment is still running:

1. Detect issue in new environment
2. Run rollback script
3. Traffic switches back to old environment
4. Investigate issue in new environment
5. Fix and redeploy

---

## Best Practices

1. Always run health checks before switching traffic
2. Keep old environment running until new version is verified
3. Monitor application after traffic switch
4. Have rollback plan ready
5. Test rollback procedure regularly
6. Document deployment process
7. Automate everything

---

## Comparison with Other Strategies

### Blue-Green vs Canary
- Blue-Green: All-at-once traffic switch
- Canary: Gradual traffic shift

### Blue-Green vs Rolling
- Blue-Green: Two complete environments
- Rolling: Update instances one at a time

---

## Cost Considerations

- Requires 2x infrastructure during deployment
- In LocalStack: Zero cost
- In AWS: Use auto-scaling to minimize cost
- Cost justified by reduced risk and downtime
