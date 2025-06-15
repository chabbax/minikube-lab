/*
  @params var.service_accounts - List of ServiceAccount definitions. Each contains:
    - name                              (string): ServiceAccount name.
    - namespace                         (string): Namespace to create the SA in.
    - labels                            (map(string)): Labels to attach.
    - annotations                       (map(string)): Annotations to attach.
    - automount_service_account_token   (bool): Whether to automount the token into pods.

  @note: Iterates over each entry in var.service_accounts using for_each.
  @note: Creates a kubernetes_service_account resource with the provided metadata.
  @note: If you disable automount_service_account_token, pods using this SA won’t receive a token by default.
*/
resource "kubernetes_service_account" "this" {
  for_each                        = { for sa in var.service_accounts : "${sa.namespace}/${sa.name}" => sa }
  automount_service_account_token = each.value.automount_service_account_token

  metadata {
    name        = each.value.name
    namespace   = each.value.namespace
    labels      = each.value.labels
    annotations = each.value.annotations
  }
}
