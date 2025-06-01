/*
  @params var.deployments  - List of deployment objects. Each contains: manifest (string): Path to a Kubernetes Deployment YAML file.

  @note: Iterates over each `manifest` path and uses `yamldecode(file(...))` to create a kubernetes_manifest resource from the YAML definition.
  @note: Ensure each YAML file defines a valid Deployment object (apiVersion: apps/v1, kind: Deployment).
*/
resource "kubernetes_manifest" "this" {
  for_each = { for f in var.deployments : f.manifest => f }

  manifest = yamldecode(file(each.value.manifest))
}
