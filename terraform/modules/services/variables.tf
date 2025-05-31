variable "services" {
  description = "List of Kubernetes Service manifest file paths"
  type = list(object({
    manifest = string
  }))

  validation {
    condition = alltrue([
      for s in var.services : can(regex("\\.ya?ml$", s.manifest))
    ])
    error_message = "Each manifest path must end with .yaml or .yml"
  }
}
