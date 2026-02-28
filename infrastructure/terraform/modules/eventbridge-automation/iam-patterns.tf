# IAM Policy Change Pattern
resource "aws_cloudwatch_event_rule" "iam_policy_change" {
  name        = "${var.project_name}-iam-policy-change"
  description = "Capture IAM policy modifications"

  event_pattern = jsonencode({
    source      = ["aws.iam"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventName = [
        "PutUserPolicy",
        "PutRolePolicy",
        "CreatePolicy",
        "AttachUserPolicy",
        "AttachRolePolicy"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "iam_policy_audit" {
  rule      = aws_cloudwatch_event_rule.iam_policy_change.name
  target_id = "IAMAuditLambda"
  arn       = var.iam_audit_lambda_arn
}

# Root Account Usage Pattern
resource "aws_cloudwatch_event_rule" "root_account_usage" {
  name        = "${var.project_name}-root-account-usage"
  description = "Alert on root account usage"

  event_pattern = jsonencode({
    source      = ["aws.signin"]
    detail-type = ["AWS Console Sign In via CloudTrail"]
    detail = {
      userIdentity = {
        type = ["Root"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "root_account_alert" {
  rule      = aws_cloudwatch_event_rule.root_account_usage.name
  target_id = "RootAccountAlertLambda"
  arn       = var.security_alert_lambda_arn
}
