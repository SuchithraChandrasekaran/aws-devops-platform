terraform {
  backend "s3" {
    bucket         = "aws-devops-tfstate-149152058755"
    key            = "aws-free-tier/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "aws-devops-tfstate-lock"
    encrypt        = true
  }
}
