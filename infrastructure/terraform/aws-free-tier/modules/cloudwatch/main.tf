variable "sns_topic_arn" {
  type = string
}

variable "ec2_instance_id" {
  type    = string
  default = "i-0eea9312c1d8fc04a"
}

variable "rds_identifier" {
  type    = string
  default = "aws-devops-db"
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name          = "ec2-cpu-high"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  period              = 300
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    InstanceId = var.ec2_instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_status" {
  alarm_name          = "ec2-status-check-failed"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  statistic           = "Maximum"
  period              = 60
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    InstanceId = var.ec2_instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "rds-cpu-high"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  period              = 300
  threshold           = 70
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "rds-low-storage"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  period              = 300
  threshold           = 2000000000
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_memory" {
  alarm_name          = "ec2-memory-high"
  metric_name         = "mem_used_percent"
  namespace           = "aws-devops/EC2"
  statistic           = "Average"
  period              = 300
  threshold           = 85
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  alarm_actions       = [var.sns_topic_arn]
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws-devops/sample-app"
  retention_in_days = 7
}
