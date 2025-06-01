variable "name" {
  description = "Helm release name (must be unique per namespace)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.name))
    error_message = "The release name must match regex ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$, i.e., DNS-1123 label format (lowercase alphanumeric, '-' allowed, must start/end with alphanumeric)."
  }
}

variable "namespace" {
  description = "Kubernetes namespace in which to install the release."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.namespace))
    error_message = "The namespace must match regex ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$, i.e., valid Kubernetes DNS-1123 label (lowercase alphanumeric, '-' allowed, must start/end with alphanumeric)."
  }
}

variable "chart_path" {
  description = "If non-empty, Terraform will install from this local filesystem path (an unpacked chart). Otherwise, Terraform expects chart + repository (and optionally version)."
  type        = string
  default     = ""
}

variable "chart" {
  description = "Name of the chart (e.g. \"nginx\"). Ignored if chart_path is non-empty."
  type        = string
  default     = ""
}

variable "repository" {
  description = "URL of the Helm chart repository (e.g. \"https://charts.bitnami.com/bitnami\"). Ignored if chart_path is non-empty."
  type        = string
  default     = ""
}

variable "version" {
  description = "Version of the chart to install (e.g. \"1.2.3\"). Only used when chart_path == \"\". If empty, Helm will install the latest matching version."
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
  description = "If true, Terraform waits until all pods, CRDs, etc. are ready before finishing."
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
  description = "How long to wait for the Helm operation before timing out (e.g. \"5m\")."
  type        = string
  default     = "5m"

  validation {
    condition     = can(regex("^\\d+[smh]$", var.timeout))
    error_message = "Timeout must be a duration string ending in 's', 'm', or 'h', for example '30s', '5m', or '1h'."
  }
}

variable "values" {
  description = "A list of paths to YAML values.yaml files that override chart defaults. Example: [\"./env/dev-values.yaml\"]. The files are applied in order; later entries override earlier ones."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for p in var.values : can(regex("\\.ya?ml$", p))])
    error_message = "Each entry in 'values' must be a path ending with .yaml or .yml."
  }
}

variable "set" {
  description = "A list of individual --set overrides in \"key=value\" form (e.g. [\"image.tag=1.2.3\", \"service.type=NodePort\"]). Use these for quick single-value tweaks without editing a full values.yaml."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for s in var.set : can(regex("^[^=]+=.+$", s))])
    error_message = "Each entry in 'set' must follow key=value format (no empty key, value required)."
  }
}

variable "dummy" {
  description = "Internal: Forces validation of chart_path vs. (chart + repository)."
  type        = bool
  default     = true

  validation {
    condition = (
      length(trimspace(var.chart_path)) > 0 ||
      (
        length(trimspace(var.chart)) > 0 &&
        length(trimspace(var.repository)) > 0
      )
    )
    error_message = "You must either set chart_path to a non-empty string (local chart directory) or set both chart and repository (remote chart + repo URL)."
  }
}
