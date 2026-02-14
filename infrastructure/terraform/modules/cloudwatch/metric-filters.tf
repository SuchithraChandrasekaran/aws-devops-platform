# Metric filter for error count from logs
resource "aws_cloudwatch_log_metric_filter" "error_count" {
  name           = "ErrorCountFromLogs"
  log_group_name = aws_cloudwatch_log_group.errors.name
  pattern        = "[ERROR]"

  metric_transformation {
    name      = "ErrorCountFromLogs"
    namespace = "MyApp/Logs"
    value     = "1"
  }
}

# Metric filter for API response time
resource "aws_cloudwatch_log_metric_filter" "api_latency" {
  name           = "APILatency"
  log_group_name = aws_cloudwatch_log_group.api.name
  pattern        = "[time, request_id, latency]"

  metric_transformation {
    name      = "APIResponseTime"
    namespace = "MyApp/Logs"
    value     = "$latency"
  }
}
