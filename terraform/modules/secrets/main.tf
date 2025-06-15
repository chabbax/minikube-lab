resource "kubernetes_secret" "token" {
  for_each = { for s in var.secrets : "${s.namespace}/${s.secret_name}" => s }

  metadata {
    name      = each.value.secret_name
    namespace = each.value.namespace
    labels    = each.value.labels
    annotations = merge(
      { "kubernetes.io/service-account.name" = each.value.service_account_name },
      each.value.annotations,
    )
  }

  type = "kubernetes.io/service-account-token"
}
