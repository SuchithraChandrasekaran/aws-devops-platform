# Rule 1: Check if S3 buckets are encrypted
resource "aws_config_config_rule" "s3_bucket_encryption" {
  name = "s3-bucket-server-side-encryption-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.main]

  tags = {
    Environment = var.environment
    Day         = "25"
    Type        = "Managed"
  }
}

# Rule 2: Check if CloudTrail is enabled
resource "aws_config_config_rule" "cloudtrail_enabled" {
  name = "cloudtrail-enabled"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.main]

  tags = {
    Environment = var.environment
    Day         = "25"
    Type        = "Managed"
  }
}

# Rule 3: Check if EC2 instances are using approved AMIs
resource "aws_config_config_rule" "approved_amis" {
  name = "approved-amis-by-id"

  source {
    owner             = "AWS"
    source_identifier = "APPROVED_AMIS_BY_ID"
  }

  input_parameters = jsonencode({
    amiIds = "ami-0abcdef1234567890,ami-0abcdef1234567891"
  })

  depends_on = [aws_config_configuration_recorder.main]

  tags = {
    Environment = var.environment
    Day         = "25"
    Type        = "Managed"
  }
}

# Rule 4: Check if IAM password policy meets requirements
resource "aws_config_config_rule" "iam_password_policy" {
  name = "iam-password-policy"

  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }

  input_parameters = jsonencode({
    RequireUppercaseCharacters = true
    RequireLowercaseCharacters = true
    RequireNumbers             = true
    MinimumPasswordLength      = 14
    MaxPasswordAge             = 90
  })

  depends_on = [aws_config_configuration_recorder.main]

  tags = {
    Environment = var.environment
    Day         = "25"
    Type        = "Managed"
  }
}

# Rule 5: Check if RDS instances are encrypted
resource "aws_config_config_rule" "rds_encryption" {
  name = "rds-storage-encrypted"

  source {
    owner             = "AWS"
    source_identifier = "RDS_STORAGE_ENCRYPTED"
  }

  depends_on = [aws_config_configuration_recorder.main]

  tags = {
    Environment = var.environment
    Day         = "25"
    Type        = "Managed"
  }
}
