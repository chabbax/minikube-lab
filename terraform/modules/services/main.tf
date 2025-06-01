/*
  @params var.services  - List of service objects. Each contains: manifest (string): Path to a Kubernetes Service YAML file.

  @note: Iterates over each `manifest` path and uses `yamldecode(file(...))` to create a kubernetes_svc resource from the YAML definition.
  @note: Ensure each YAML file defines a valid Service object (apiVersion: v1, kind: Service).
*/
resource "kubernetes_manifest" "services" {
  for_each = { for s in var.services : s.manifest => s }

  manifest = yamldecode(file(each.value.manifest))
}
