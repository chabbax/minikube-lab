# File: terraform/modules/helm_release/variables.tf

variable "name" {
  description = "Helm release name (must be unique per namespace)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.name))
    error_message = "The release name must match DNS-1123 label format (lowercase alphanumeric, '-' allowed, must start/end with alphanumeric)."
  }
}

variable "namespace" {
  description = "Kubernetes namespace in which to install the release."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.namespace))
    error_message = "The namespace must match DNS-1123 label format (lowercase alphanumeric, '-' allowed, must start/end with alphanumeric)."
  }
}

variable "chart_path" {
  description = "If non-empty, Terraform will install from this local filesystem path (an unpacked chart). Otherwise, Terraform expects chart + repository (and optionally chart_version)."
  type        = string
  default     = ""
}

variable "chart" {
  description = "Name of the remote chart (e.g. \"nginx\"). Ignored if chart_path is non-empty."
  type        = string
  default     = ""
}

variable "repository" {
  description = "URL of the Helm chart repository (e.g. \"https://charts.bitnami.com/bitnami\"). Ignored if chart_path is non-empty."
  type        = string
  default     = ""
}

variable "chart_version" {
  description = "Version of the chart to install (e.g. \"1.2.3\"). Only used when chart_path == \"\"; if empty, Helm installs the latest matching version."
  type        = string
  default     = ""
}

variable "create_namespace" {
  description = "If true, Helm will automatically create the target namespace before installing."
  type        = bool
  default     = true
}

variable "atomic" {
  description = "If true, the release will be rolled back automatically on failure."
  type        = bool
  default     = true
}

variable "wait" {
  description = "If true, Terraform waits until all Pods/CRDs/etc. are ready before finishing."
  type        = bool
  default     = true
}

variable "wait_for_jobs" {
  description = "If true, Terraform waits for any Kubernetes Jobs in the chart to complete before finishing."
  type        = bool
  default     = true
}

variable "dependency_update" {
  description = "If true, runs `helm dependency update` before installing or upgrading the chart."
  type        = bool
  default     = true
}

variable "timeout" {
  description = "Time in seconds to wait for each Kubernetes operation."
  type        = number
  default     = 300

  validation {
    condition     = var.timeout > 0
    error_message = "timeout must be a positive integer (seconds)."
  }
}

variable "values" {
  description = "A list of YAML‐content strings that override chart defaults. Use file(\"…\") to load from disk."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for v in var.values : can(yamldecode(v))])
    error_message = "Each entry in 'values' must be valid YAML content (e.g. use file(\"path/to/values.yaml\"))."
  }
}

variable "set" {
  description = "A list of individual --set overrides in \"key=value\" form (e.g. [\"image.tag=1.2.3\", \"service.type=NodePort\"])."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for s in var.set : can(regex("^[^=]+=.+$", s))])
    error_message = "Each entry in 'set' must follow key=value format (no empty key, value required)."
  }
}
