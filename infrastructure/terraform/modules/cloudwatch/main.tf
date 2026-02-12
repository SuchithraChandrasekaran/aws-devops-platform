# CloudWatch Log Group for application logs
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/localstack/myapp"
  retention_in_days = 7

  tags = {
    Environment = "dev"
    Day         = "15"
    ManagedBy   = "terraform"
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "monitoring" {
  dashboard_name = "myapp-metrics-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["MyApp/Performance", "RequestCount"],
            ["MyApp/Performance", "ResponseTime"],
            ["MyApp/Performance", "ErrorCount"]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "Application Performance Metrics"
        }
      }
    ]
  })
}
