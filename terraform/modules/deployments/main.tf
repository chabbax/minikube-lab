
/*
    @params deployments - List of deployment manifest file paths with associated name and namespace
*/
resource "kubernetes_manifest" "this" {
  for_each = { for f in var.deployments : f.manifest => f }

  manifest = yamldecode(file(each.value.manifest))
}
