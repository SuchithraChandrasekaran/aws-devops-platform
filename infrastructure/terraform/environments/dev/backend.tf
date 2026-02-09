# Remote Backend Configuration for LocalStack

terraform {
  backend "s3" {
    bucket  = "terraform-state-devops-platform"
    key     = "dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    
    # DynamoDB locking (old parameter for compatibility)
    dynamodb_table = "terraform-state-locks"
    
    # LocalStack configuration
    endpoint                    = "http://localhost:4566"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
    
    access_key = "test"
    secret_key = "test"
    
    # Additional LocalStack endpoints
    dynamodb_endpoint = "http://localhost:4566"
    iam_endpoint      = "http://localhost:4566"
    sts_endpoint      = "http://localhost:4566"
  }
}
