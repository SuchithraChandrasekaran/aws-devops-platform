variable "s3_bucket_name" {
  type = string
}

variable "config_role_arn" {
  type = string
}

resource "aws_config_configuration_recorder" "main" {
  name     = "aws-devops-recorder"
  role_arn = var.config_role_arn

  recording_group {
    all_supported = false
    resource_types = [
      "AWS::EC2::Instance",
      "AWS::S3::Bucket",
      "AWS::IAM::Role",
      "AWS::RDS::DBInstance",
      "AWS::Lambda::Function"
    ]
  }
}

resource "aws_config_delivery_channel" "main" {
  name           = "aws-devops-delivery"
  s3_bucket_name = var.s3_bucket_name
  depends_on     = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "required_tags" {
  name = "required-tags"
  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }
  input_parameters = jsonencode({ tag1Key = "Project", tag2Key = "Environment" })
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "s3_encryption" {
  name = "s3-bucket-server-side-encryption-enabled"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "s3_public_read" {
  name = "s3-bucket-public-read-prohibited"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "rds_encrypted" {
  name = "rds-storage-encrypted"
  source {
    owner             = "AWS"
    source_identifier = "RDS_STORAGE_ENCRYPTED"
  }
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "iam_root_key" {
  name = "iam-root-access-key-check"
  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }
  depends_on = [aws_config_configuration_recorder.main]
}
