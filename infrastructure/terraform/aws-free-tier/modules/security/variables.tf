variable "vpc_id" {
  type = string
}

variable "database_url" {
  type      = string
  sensitive = true
}
