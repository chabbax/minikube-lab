variable "cluster_role_bindings" {
  description = "List of ClusterRoleBindings to create"
  type = list(object({
    name        = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
    subjects = list(object({
      kind      = string
      name      = string
      namespace = optional(string)
      api_group = optional(string, "")
    }))
    role_ref = object({
      api_group = string
      kind      = string
      name      = string
    })
  }))

  validation {
    condition = alltrue([
      length(var.cluster_role_bindings) > 0,
      alltrue([for b in var.cluster_role_bindings : length(b.subjects) > 0]),
      alltrue([
        for b in var.cluster_role_bindings : alltrue([
          for s in b.subjects : contains(
            ["ServiceAccount", "User", "Group"],
            s.kind
          )
        ])
      ]),
      alltrue([
        for b in var.cluster_role_bindings : alltrue([
          for s in b.subjects : (
            s.kind != "ServiceAccount" ||
            (s.namespace != "" && s.namespace != null)
          )
        ])
      ]),
      alltrue([for b in var.cluster_role_bindings : b.role_ref.kind == "ClusterRole"])
    ])

    error_message = <<-EOT
      Each cluster_role_binding entry must:
        • contain at least one binding
        • have at least one subject
        • each subject.kind must be ServiceAccount, User, or Group
        • if subject.kind = ServiceAccount, namespace must be non-empty
        • role_ref.kind must be "ClusterRole"
    EOT
  }
}
