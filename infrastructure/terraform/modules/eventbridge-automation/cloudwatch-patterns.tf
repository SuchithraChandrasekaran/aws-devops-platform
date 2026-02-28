# CloudWatch Alarm State Change Pattern
resource "aws_cloudwatch_event_rule" "alarm_state_change" {
  name        = "${var.project_name}-alarm-state-change"
  description = "Capture CloudWatch alarm state changes"

  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
    detail = {
      state = {
        value = ["ALARM", "OK"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "alarm_handler" {
  rule      = aws_cloudwatch_event_rule.alarm_state_change.name
  target_id = "AlarmHandlerLambda"
  arn       = var.alarm_handler_lambda_arn

  input_transformer {
    input_paths = {
      alarm_name = "$.detail.alarmName"
      state      = "$.detail.state.value"
      reason     = "$.detail.state.reason"
    }
    input_template = jsonencode({
      alarm_name = "<alarm_name>"
      new_state  = "<state>"
      reason     = "<reason>"
    })
  }
}
