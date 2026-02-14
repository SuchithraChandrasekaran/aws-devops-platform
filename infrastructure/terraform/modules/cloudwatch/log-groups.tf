# Application log groups
resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/application/myapp"
  retention_in_days = 7

  tags = {
    Environment = var.environment
    Service     = "application"
    Day         = "16"
  }
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/api/myapp"
  retention_in_days = 7

  tags = {
    Environment = var.environment
    Service     = "api"
    Day         = "16"
  }
}

resource "aws_cloudwatch_log_group" "errors" {
  name              = "/aws/errors/myapp"
  retention_in_days = 14

  tags = {
    Environment = var.environment
    Service     = "errors"
    Day         = "16"
  }
}

# Log streams for each group
resource "aws_cloudwatch_log_stream" "app_stream" {
  name           = "app-stream"
  log_group_name = aws_cloudwatch_log_group.application.name
}

resource "aws_cloudwatch_log_stream" "api_stream" {
  name           = "api-stream"
  log_group_name = aws_cloudwatch_log_group.api.name
}

resource "aws_cloudwatch_log_stream" "error_stream" {
  name           = "error-stream"
  log_group_name = aws_cloudwatch_log_group.errors.name
}
