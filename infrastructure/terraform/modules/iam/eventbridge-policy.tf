# Policy for EventBridge event publishing
resource "aws_iam_policy" "eventbridge_put_events" {
  name        = "${var.project_name}-eventbridge-put-events"
  description = "Allow publishing events to EventBridge"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "events:PutEvents"
        ]
        Resource = [
          "arn:aws:events:*:*:event-bus/${var.project_name}-*",
          "arn:aws:events:*:*:event-bus/default"
        ]
      }
    ]
  })

  tags = {
    Environment = var.environment
    Day         = "22"
    Purpose     = "EventBridge"
  }
}
