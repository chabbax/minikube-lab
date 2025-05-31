variable "taints" {
  description = "List of taints to apply to nodes"
  type = list(object({
    node_name = string
    key       = string
    value     = string
    effect    = string
  }))

  validation {
    condition = alltrue([
      for t in var.taints : contains(["NoSchedule", "PreferNoSchedule", "NoExecute"], t.effect)
    ])
    error_message = "Effect must be one of: NoSchedule, PreferNoSchedule, or NoExecute."
  }
}
