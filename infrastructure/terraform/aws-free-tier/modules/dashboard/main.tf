variable "instance_id" {
  type = string
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "aws-devops-platform"
  dashboard_body = file("${path.module}/dashboard.json")
}

output "dashboard_url" {
  value = "https://us-east-1.console.aws.amazon.com/cloudwatch/home#dashboards:name=aws-devops-platform"
}
