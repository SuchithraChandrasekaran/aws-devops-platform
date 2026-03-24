variable "sns_topic_arn" {
  type = string
}

variable "account_id" {
  type = string
}

resource "aws_cloudwatch_metric_alarm" "billing_1_usd" {
  alarm_name          = "Billing-Alert-1-USD"
  alarm_description   = "Alert when estimated charges exceed $1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  statistic           = "Maximum"
  period              = 86400
  threshold           = 1
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  alarm_actions       = [var.sns_topic_arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    Currency = "USD"
  }
}

resource "aws_cloudwatch_metric_alarm" "billing_5_usd" {
  alarm_name          = "Billing-Alert-5-USD"
  alarm_description   = "CRITICAL - estimated charges exceed $5"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  statistic           = "Maximum"
  period              = 86400
  threshold           = 5
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  alarm_actions       = [var.sns_topic_arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    Currency = "USD"
  }
}

resource "aws_budgets_budget" "monthly" {
  name         = "aws-devops-monthly-budget"
  budget_type  = "COST"
  limit_amount = "5"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_sns_topic_arns  = [var.sns_topic_arn]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_sns_topic_arns  = [var.sns_topic_arn]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_sns_topic_arns  = [var.sns_topic_arn]
  }
}

resource "aws_budgets_budget" "rds" {
  name         = "rds-service-budget"
  budget_type  = "COST"
  limit_amount = "1"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "Service"
    values = ["Amazon Relational Database Service"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 1
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_sns_topic_arns  = [var.sns_topic_arn]
  }
}
