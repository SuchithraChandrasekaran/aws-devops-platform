resource "aws_cloudtrail" "main" {
  name                          = "aws-devops-trail"
  s3_bucket_name                = var.s3_bucket_name
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_logging                = true
}

variable "s3_bucket_name" {
  type = string
}
