# 1. CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "MyApp/Metrics"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Triggers when CPU exceeds 80%"
  alarm_actions       = [var.critical_topic_arn]

  tags = {
    Day = "17"
  }
}

# 2. Memory Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "high-memory-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "MyApp/Metrics"
  period              = 300
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "Triggers when memory exceeds 85%"
  alarm_actions       = [var.critical_topic_arn]

  tags = {
    Day = "17"
  }
}

# 3. Error Count Alarm
resource "aws_cloudwatch_metric_alarm" "high_errors" {
  alarm_name          = "high-error-count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ErrorCountFromLogs"
  namespace           = "MyApp/Logs"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Triggers when errors exceed 10 per 5 min"
  alarm_actions       = [var.critical_topic_arn]

  tags = {
    Day = "17"
  }
}

# 4. API Latency Alarm
resource "aws_cloudwatch_metric_alarm" "high_latency" {
  alarm_name          = "high-api-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "APIResponseTime"
  namespace           = "MyApp/Logs"
  period              = 300
  statistic           = "Average"
  threshold           = 1000
  alarm_description   = "Triggers when API latency exceeds 1s"
  alarm_actions       = [var.warning_topic_arn]

  tags = {
    Day = "17"
  }
}

# 5. Disk Usage Alarm
resource "aws_cloudwatch_metric_alarm" "high_disk" {
  alarm_name          = "high-disk-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DiskUtilization"
  namespace           = "MyApp/Metrics"
  period              = 300
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Triggers when disk usage exceeds 90%"
  alarm_actions       = [var.critical_topic_arn]

  tags = {
    Day = "17"
  }
}

# 6. Network Throughput Alarm
resource "aws_cloudwatch_metric_alarm" "high_network" {
  alarm_name          = "high-network-throughput"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "NetworkThroughput"
  namespace           = "MyApp/Metrics"
  period              = 300
  statistic           = "Average"
  threshold           = 1000000
  alarm_description   = "Triggers when network exceeds 1MB/s"
  alarm_actions       = [var.warning_topic_arn]

  tags = {
    Day = "17"
  }
}

# 7. Request Count Alarm (Low Traffic)
resource "aws_cloudwatch_metric_alarm" "low_requests" {
  alarm_name          = "low-request-count"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "RequestCount"
  namespace           = "MyApp/Metrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Triggers when requests drop below 10 per 5 min"
  alarm_actions       = [var.warning_topic_arn]

  tags = {
    Day = "17"
  }
}

# 8. Database Connection Alarm
resource "aws_cloudwatch_metric_alarm" "db_connections" {
  alarm_name          = "high-db-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "MyApp/Metrics"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Triggers when DB connections exceed 80"
  alarm_actions       = [var.critical_topic_arn]

  tags = {
    Day = "17"
  }
}

# 9. Cache Hit Rate Alarm
resource "aws_cloudwatch_metric_alarm" "low_cache_hit" {
  alarm_name          = "low-cache-hit-rate"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CacheHitRate"
  namespace           = "MyApp/Metrics"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Triggers when cache hit rate below 70%"
  alarm_actions       = [var.warning_topic_arn]

  tags = {
    Day = "17"
  }
}

# 10. Queue Depth Alarm
resource "aws_cloudwatch_metric_alarm" "high_queue_depth" {
  alarm_name          = "high-queue-depth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "QueueDepth"
  namespace           = "MyApp/Metrics"
  period              = 300
  statistic           = "Maximum"
  threshold           = 100
  alarm_description   = "Triggers when queue depth exceeds 100"
  alarm_actions       = [var.critical_topic_arn]

  tags = {
    Day = "17"
  }
}

# Composite alarm for system health
resource "aws_cloudwatch_composite_alarm" "system_unhealthy" {
  alarm_name          = "system-unhealthy"
  alarm_description   = "Triggers when multiple critical conditions met"
  actions_enabled     = true
  alarm_actions       = [var.critical_topic_arn]

  alarm_rule = "ALARM(high-cpu-utilization) OR ALARM(high-memory-utilization) OR (ALARM(high-error-count) AND ALARM(high-api-latency))"

  tags = {
    Day = "17"
  }
}
