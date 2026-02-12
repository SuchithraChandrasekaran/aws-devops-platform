# Drift Detection Report - Day 14

## Manual Changes Introduced

### 1. VPC Tags
**Resource**: VPC managed by Terraform
**Changes Made**:
- Added tag: ManualTag=OutsideTerraform
- Added tag: DriftTest=Day14

**Terraform Detection**: ✓ Detected
**Impact**: Terraform will remove these tags on next apply

### 2. SSM Parameter Value
**Resource**: /dev/devops-platform/app/version
**Changes Made**:
- Old value: 1.1.0
- New value: 2.5.0-manual-change (manual update)
- Version incremented: 1 → 2

**Terraform Detection**: ✓ Detected
**Impact**: Terraform will reset value to 1.1.0

### 3. New SSM Parameter
**Resource**: /dev/devops-platform/manual/drift-test
**Changes Made**:
- Created new parameter outside Terraform
- Value: "created-outside-terraform"

**Terraform Detection**: ✗ Not tracked (expected - not in state)
**Impact**: Will remain until manually deleted or imported

## Drift Detection Results

### Command Used
```bash
terraform plan -detailed-exitcode
```

### Exit Code
2 (drift detected)

### Resources with Drift
1. module.vpc - VPC tags modified
2. module.ssm_parameters.aws_ssm_parameter.parameter["app_version"] - value changed

### Resources Not Tracked
1. /dev/devops-platform/manual/drift-test - created outside Terraform

## How Drift Was Detected

Terraform compared:
- Current state in S3 backend
- Actual infrastructure in LocalStack
- Desired state in .tf files

Found discrepancies and flagged them for correction.

## Remediation Options

### Option 1: Restore to Terraform State (Recommended)
```bash
terraform apply -auto-approve
```
This reverts all managed resources to defined state.

### Option 2: Update Terraform to Match Reality
```bash
# If manual changes were intentional
# Update variables or .tf files
# Then: terraform apply
```

### Option 3: Import Unmanaged Resources
```bash
terraform import 'module.ssm_parameters.aws_ssm_parameter.parameter["manual_drift_test"]' \
  /dev/devops-platform/manual/drift-test
```

## Prevention Strategies

1. **IAM Policies**: Restrict console/API access
2. **CI/CD Gates**: Run drift detection before deployments
3. **Monitoring**: Alert on out-of-band changes
4. **Regular Checks**: Daily drift detection
5. **Tagging**: All resources tagged ManagedBy=Terraform

## Lessons Learned

1. Terraform reliably detects configuration drift
2. Sensitive values are masked but changes still detected
3. Unmanaged resources need manual tracking
4. Version increments indicate manual modifications
5. Drift detection should be automated

## Next Steps

1. Fix drift: `terraform apply`
2. Automate drift checks in CI/CD
3. Set up alerts for manual changes
4. Document approved change procedures
