resource "aws_db_subnet_group" "main" {
  name       = "aws-devops-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name    = "aws-devops-db-subnet-group"
    Project = "aws-devops-platform"
    Day     = "38"
  }
}
