# Rule 1: CloudWatch Alarm state change
resource "aws_cloudwatch_event_rule" "alarm_state_change" {
  name        = "alarm-state-change"
  description = "Capture CloudWatch alarm state changes"
  event_bus_name = "default"

  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
    detail = {
      state = {
        value = ["ALARM"]
      }
    }
  })

  tags = {
    Environment = var.environment
    Day         = "20"
    Type        = "pattern"
  }
}

# Rule 2: EC2 instance state change
resource "aws_cloudwatch_event_rule" "ec2_state_change" {
  name        = "ec2-state-change"
  description = "Capture EC2 instance state changes"
  event_bus_name = "default"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      state = ["stopped", "terminated"]
    }
  })

  tags = {
    Environment = var.environment
    Day         = "20"
    Type        = "pattern"
  }
}

# Rule 3: Custom application error event
resource "aws_cloudwatch_event_rule" "app_error_event" {
  name           = "app-error-event"
  description    = "Capture custom application error events"
  event_bus_name = aws_cloudwatch_event_bus.app_events.name

  event_pattern = jsonencode({
    source      = ["myapp.backend"]
    detail-type = ["ApplicationError"]
    detail = {
      severity = ["CRITICAL", "HIGH"]
    }
  })

  tags = {
    Environment = var.environment
    Day         = "20"
    Type        = "pattern"
  }
}

# Rule 4: Custom deployment event
resource "aws_cloudwatch_event_rule" "deployment_event" {
  name           = "deployment-event"
  description    = "Capture deployment events"
  event_bus_name = aws_cloudwatch_event_bus.app_events.name

  event_pattern = jsonencode({
    source      = ["myapp.cicd"]
    detail-type = ["DeploymentCompleted", "DeploymentFailed"]
  })

  tags = {
    Environment = var.environment
    Day         = "20"
    Type        = "pattern"
  }
}

# Targets for pattern-based rules
resource "aws_cloudwatch_event_target" "alarm_state_target" {
  rule = aws_cloudwatch_event_rule.alarm_state_change.name
  arn  = var.critical_topic_arn

  input_transformer {
    input_paths = {
      alarm_name = "$.detail.alarmName"
      state      = "$.detail.state.value"
      reason     = "$.detail.state.reason"
    }
    input_template = "\"ALARM TRIGGERED: <alarm_name> changed to <state>. Reason: <reason>\""
  }
}

resource "aws_cloudwatch_event_target" "ec2_state_target" {
  rule = aws_cloudwatch_event_rule.ec2_state_change.name
  arn  = var.warning_topic_arn

  input_transformer {
    input_paths = {
      instance_id = "$.detail.instance-id"
      state       = "$.detail.state"
    }
    input_template = "\"EC2 ALERT: Instance <instance_id> changed to <state>\""
  }
}

resource "aws_cloudwatch_event_target" "app_error_target" {
  rule           = aws_cloudwatch_event_rule.app_error_event.name
  event_bus_name = aws_cloudwatch_event_bus.app_events.name
  arn            = var.critical_topic_arn

  input_transformer {
    input_paths = {
      error_type = "$.detail.errorType"
      severity   = "$.detail.severity"
      service    = "$.detail.service"
    }
    input_template = "\"APP ERROR: <severity> error in <service>: <error_type>\""
  }
}

resource "aws_cloudwatch_event_target" "deployment_target" {
  rule           = aws_cloudwatch_event_rule.deployment_event.name
  event_bus_name = aws_cloudwatch_event_bus.app_events.name
  arn            = var.warning_topic_arn

  input_transformer {
    input_paths = {
      environment = "$.detail.environment"
      version     = "$.detail.version"
      status      = "$.detail-type"
    }
    input_template = "\"DEPLOYMENT: <status> for version <version> in <environment>\""
  }
}
