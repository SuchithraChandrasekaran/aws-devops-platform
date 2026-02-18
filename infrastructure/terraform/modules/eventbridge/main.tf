# Custom Event Bus for application events
resource "aws_cloudwatch_event_bus" "app_events" {
  name = "myapp-event-bus"

  tags = {
    Environment = var.environment
    Day         = "20"
  }
}
