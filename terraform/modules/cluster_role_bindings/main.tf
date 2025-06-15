/*
  @params var.cluster_role_bindings - List of ClusterRoleBinding definitions. Each contains:
    - name            (string): CRB name.
    - labels          (map(string)): Labels to attach.
    - annotations     (map(string)): Annotations to attach.
    - subjects        (list(object)): Each subject object must include:
        • kind        (string)
        • name        (string)
        • namespace   (optional string)
        • api_group   (string)
    - role_ref        (object): Specifies the role to bind:
        • api_group   (string)
        • kind        (string)
        • name        (string)

  @note: Iterates over var.cluster_role_bindings to create a kubernetes_cluster_role_binding per entry.
  @note: Uses a dynamic "subject" block to configure each subject.
  @note: role_ref must match an existing ClusterRole (or Role) in the cluster.
*/
resource "kubernetes_cluster_role_binding" "this" {
  for_each = { for crb in var.cluster_role_bindings : crb.name => crb }

  metadata {
    name        = each.value.name
    labels      = each.value.labels
    annotations = each.value.annotations
  }

  dynamic "subject" {
    for_each = each.value.subjects
    content {
      kind      = subject.value.kind
      name      = subject.value.name
      namespace = lookup(subject.value, "namespace", null)
      api_group = lookup(subject.value, "api_group", "")
    }
  }

  role_ref {
    api_group = each.value.role_ref.api_group
    kind      = each.value.role_ref.kind
    name      = each.value.role_ref.name
  }
}
