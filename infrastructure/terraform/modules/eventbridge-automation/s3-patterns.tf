# S3 Bucket Creation Pattern
resource "aws_cloudwatch_event_rule" "s3_bucket_created" {
  name        = "${var.project_name}-s3-bucket-created"
  description = "Capture S3 bucket creation events"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventName = ["CreateBucket"]
    }
  })
}

resource "aws_cloudwatch_event_target" "s3_bucket_secure" {
  rule      = aws_cloudwatch_event_rule.s3_bucket_created.name
  target_id = "S3SecurityLambda"
  arn       = var.s3_security_lambda_arn
}

# S3 Public Access Change Pattern
resource "aws_cloudwatch_event_rule" "s3_public_access" {
  name        = "${var.project_name}-s3-public-access"
  description = "Capture S3 public access configuration changes"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventName = [
        "PutBucketAcl",
        "PutBucketPolicy",
        "DeletePublicAccessBlock"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "s3_public_remediate" {
  rule      = aws_cloudwatch_event_rule.s3_public_access.name
  target_id = "S3RemediationLambda"
  arn       = var.s3_remediation_lambda_arn
}
