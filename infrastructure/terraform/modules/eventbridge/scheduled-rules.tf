# Rule 1: Health check every 5 minutes
resource "aws_cloudwatch_event_rule" "health_check" {
  name                = "app-health-check"
  description         = "Trigger health check every 5 minutes"
  schedule_expression = "rate(5 minutes)"

  tags = {
    Environment = var.environment
    Day         = "20"
    Type        = "scheduled"
  }
}

# Rule 2: Daily cleanup at midnight
resource "aws_cloudwatch_event_rule" "daily_cleanup" {
  name                = "daily-cleanup"
  description         = "Trigger daily cleanup at midnight UTC"
  schedule_expression = "cron(0 0 * * ? *)"

  tags = {
    Environment = var.environment
    Day         = "20"
    Type        = "scheduled"
  }
}

# Rule 3: Weekly report every Monday 9am
resource "aws_cloudwatch_event_rule" "weekly_report" {
  name                = "weekly-report"
  description         = "Generate weekly report every Monday 9am UTC"
  schedule_expression = "cron(0 9 ? * MON *)"

  tags = {
    Environment = var.environment
    Day         = "20"
    Type        = "scheduled"
  }
}

# Rule 4: Metric collection every minute
resource "aws_cloudwatch_event_rule" "metric_collection" {
  name                = "metric-collection"
  description         = "Collect metrics every minute"
  schedule_expression = "rate(1 minute)"

  tags = {
    Environment = var.environment
    Day         = "20"
    Type        = "scheduled"
  }
}

# Targets for scheduled rules - SNS notifications
resource "aws_cloudwatch_event_target" "health_check_target" {
  rule = aws_cloudwatch_event_rule.health_check.name
  arn  = var.critical_topic_arn

  input = jsonencode({
    event   = "HealthCheck"
    message = "Scheduled health check triggered"
    time    = "auto"
  })
}

resource "aws_cloudwatch_event_target" "daily_cleanup_target" {
  rule = aws_cloudwatch_event_rule.daily_cleanup.name
  arn  = var.warning_topic_arn

  input = jsonencode({
    event   = "DailyCleanup"
    message = "Daily cleanup job triggered"
  })
}

resource "aws_cloudwatch_event_target" "weekly_report_target" {
  rule = aws_cloudwatch_event_rule.weekly_report.name
  arn  = var.warning_topic_arn

  input = jsonencode({
    event   = "WeeklyReport"
    message = "Weekly report generation triggered"
  })
}
