terraform {
  backend "s3" {
    bucket         = "terraform-state-devops-platform"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true

    endpoints = {
      s3         = "http://localhost:4566"
      dynamodb   = "http://localhost:4566"
    }

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}
