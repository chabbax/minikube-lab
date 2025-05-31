variable "default_labels" {
  description = "Default labels applied to all namespaces"
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.default_labels : (
        length(k) <= 63 &&
        can(regex("^[A-Za-z0-9]([-A-Za-z0-9_.]*[A-Za-z0-9])?$", k)) &&
        (length(v) == 0 || (
          length(v) <= 63 &&
          can(regex("^[A-Za-z0-9]([-A-Za-z0-9_.]*[A-Za-z0-9])?$", v))
        ))
      )
    ])
    error_message = "Label keys and values must be <=63 characters, alphanumeric, may include '-', '_', '.', must start and end with alphanumeric."
  }
}

variable "namespaces" {
  description = "List of namespaces to create"
  type = list(object({
    name        = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
  }))

  validation {
    condition = alltrue([
      for ns in var.namespaces : (
        length(ns.name) <= 63 &&
        can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", ns.name)) &&

        alltrue([
          for k, v in lookup(ns, "labels", {}) : (
            length(k) <= 63 &&
            can(regex("^[A-Za-z0-9]([-A-Za-z0-9_.]*[A-Za-z0-9])?$", k)) &&
            (length(v) == 0 || (
              length(v) <= 63 &&
              can(regex("^[A-Za-z0-9]([-A-Za-z0-9_.]*[A-Za-z0-9])?$", v))
            ))
          )
        ]) &&

        alltrue([
          for k, v in lookup(ns, "annotations", {}) : (
            length(k) <= 253 &&
            can(regex("^([A-Za-z0-9]([-A-Za-z0-9_.]*[A-Za-z0-9])?)(/[A-Za-z0-9]([-A-Za-z0-9_.]*[A-Za-z0-9])?)?$", k))
          )
        ])
      )
    ])
    error_message = "Namespace names must be DNS-1123 compliant. Label keys/values must be <=63 characters and valid. Annotation keys <=253 characters with optional prefix."
  }
}
