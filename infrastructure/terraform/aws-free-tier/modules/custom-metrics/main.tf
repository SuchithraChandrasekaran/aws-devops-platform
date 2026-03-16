variable "instance_id" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}

resource "aws_cloudwatch_metric_alarm" "app_errors" {
  alarm_name          = "app-error-count-high"
  alarm_description   = "App error count above 10 in 5 minutes"
  metric_name         = "ErrorCount"
  namespace           = "aws-devops/App"
  statistic           = "Sum"
  period              = 300
  threshold           = 10
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    InstanceId = var.instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "app_response_time" {
  alarm_name          = "app-response-time-high"
  alarm_description   = "App response time above 500ms average"
  metric_name         = "ResponseTime"
  namespace           = "aws-devops/App"
  statistic           = "Average"
  period              = 300
  threshold           = 500
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    InstanceId = var.instance_id
  }
}
