module "ssm_parameters" {
  source = "../../modules/ssm-parameters"

  environment = "dev"

  parameters = {
    app_name = {
      name        = "/dev/devops-platform/app/name"
      value       = "devops-platform"
      description = "Application name"
      type        = "String"
    }

    app_version = {
      name        = "/dev/devops-platform/app/version"
      value       = "1.0.0"
      description = "Application version"
      type        = "String"
    }

    app_environment = {
      name        = "/dev/devops-platform/app/environment"
      value       = "dev"
      description = "Environment name"
      type        = "String"
    }

    db_host = {
      name        = "/dev/devops-platform/database/host"
      value       = "localhost"
      description = "Database host"
      type        = "String"
    }

    db_port = {
      name        = "/dev/devops-platform/database/port"
      value       = "5432"
      description = "Database port"
      type        = "String"
    }
  }
}

output "ssm_parameter_names" {
  value = module.ssm_parameters.parameter_names
}
