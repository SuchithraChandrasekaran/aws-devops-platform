resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-devops-platform"

  tags = {
    Name        = "Terraform State Bucket"
    Purpose     = "Remote state storage"
    Environment = "shared"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}
