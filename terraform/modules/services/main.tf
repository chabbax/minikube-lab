
resource "kubernetes_manifest" "this" {
  for_each = { for s in var.services : s.manifest => s }

  manifest = yamldecode(file(each.value.manifest))
}
