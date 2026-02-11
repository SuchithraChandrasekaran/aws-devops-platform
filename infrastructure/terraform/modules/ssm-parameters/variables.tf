variable "environment" {
  description = "Environment name"
  type        = string
}

variable "parameters" {
  description = "Map of parameters to create"
  type = map(object({
    name        = string
    value       = string
    type        = optional(string)
    description = optional(string)
    tier        = optional(string)
    tags        = optional(map(string))
  }))
  default = {}
}
