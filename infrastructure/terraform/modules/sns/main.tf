# SNS topic for critical alarms
resource "aws_sns_topic" "critical_alerts" {
  name = "critical-alerts"

  tags = {
    Environment = var.environment
    Day         = "17"
  }
}

# SNS topic for warning alarms
resource "aws_sns_topic" "warning_alerts" {
  name = "warning-alerts"

  tags = {
    Environment = var.environment
    Day         = "17"
  }
}

# SNS topic for info notifications
resource "aws_sns_topic" "info_alerts" {
  name = "info-alerts"

  tags = {
    Environment = var.environment
    Day         = "17"
  }
}

# Email subscription for critical alerts
resource "aws_sns_topic_subscription" "critical_email" {
  topic_arn = aws_sns_topic.critical_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
