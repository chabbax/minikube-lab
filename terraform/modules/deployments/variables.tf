variable "deployments" {
  description = "List of deployment YAML file paths"
  type = list(object({
    manifest = string
  }))

  validation {
    condition = alltrue([
      for d in var.deployments : can(regex("\\.ya?ml$", d.manifest))
    ])
    error_message = "Each manifest path must end with .yaml or .yml"
  }
}
