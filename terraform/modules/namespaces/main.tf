/*
  @params namespaces      - List of namespaces to create. Each contains: name (string), labels (optional map(string)), annotations (optional map(string))
  @params default_labels  - Common labels applied to all namespaces. Overridden by namespace-specific labels.

  @note: Uses merge to combine default and custom labels.
  @note: Uses try to safely handle missing optional fields.
  @note: prevent_destroy avoids accidental deletion of namespaces.
*/
resource "kubernetes_namespace" "this" {
  for_each = { for ns in var.namespaces : ns.name => ns }

  metadata {
    name        = each.value.name
    labels      = merge(var.default_labels, try(each.value.labels, {}))
    annotations = try(each.value.annotations, {})
  }

  lifecycle {
    prevent_destroy = true
  }
}
