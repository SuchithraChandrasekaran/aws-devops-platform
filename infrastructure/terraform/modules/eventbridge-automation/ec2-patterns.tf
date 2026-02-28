# EC2 Instance State Change Pattern
resource "aws_cloudwatch_event_rule" "ec2_state_change" {
  name        = "${var.project_name}-ec2-state-change"
  description = "Capture EC2 instance state changes"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      state = ["stopped", "terminated", "stopping", "running"]
    }
  })
}

resource "aws_cloudwatch_event_target" "ec2_state_lambda" {
  rule      = aws_cloudwatch_event_rule.ec2_state_change.name
  target_id = "EC2StateHandlerLambda"
  arn       = var.ec2_handler_lambda_arn
}

# EC2 Instance Launch Pattern
resource "aws_cloudwatch_event_rule" "ec2_launch" {
  name        = "${var.project_name}-ec2-launch"
  description = "Capture new EC2 instance launches"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      state = ["running"]
    }
  })
}

resource "aws_cloudwatch_event_target" "ec2_launch_tagger" {
  rule      = aws_cloudwatch_event_rule.ec2_launch.name
  target_id = "AutoTagLambda"
  arn       = var.auto_tag_lambda_arn
}

# EC2 Security Group Change Pattern
resource "aws_cloudwatch_event_rule" "security_group_change" {
  name        = "${var.project_name}-sg-change"
  description = "Capture security group modifications"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventName = [
        "AuthorizeSecurityGroupIngress",
        "RevokeSecurityGroupIngress",
        "CreateSecurityGroup"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "sg_change_audit" {
  rule      = aws_cloudwatch_event_rule.security_group_change.name
  target_id = "SecurityAuditLambda"
  arn       = var.security_audit_lambda_arn
}
