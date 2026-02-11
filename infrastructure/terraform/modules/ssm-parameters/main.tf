resource "aws_ssm_parameter" "parameter" {
  for_each = var.parameters

  name        = each.value.name
  description = lookup(each.value, "description", null)
  type        = lookup(each.value, "type", "String")
  value       = each.value.value
  tier        = lookup(each.value, "tier", "Standard")

  tags = merge(
    {
      Name        = each.value.name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    lookup(each.value, "tags", {})
  )
}
