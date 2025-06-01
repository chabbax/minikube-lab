# Install from local path (air‐gapped) using chart_pat
# Install from a remote repository by leaving chart_path="" and set chart + repository + version.

module "argocd" {
  source            = "../../terraform/modules/helm_release"
  name              = "argocd"
  namespace         = "argocd"
  chart_path        = "${path.root}/../../helm/charts/argocd"
  create_namespace  = true
  atomic            = true
  wait              = true
  wait_for_jobs     = true
  dependency_update = true
  timeout           = "5m"

  values = [
    "${path.root}/helm/charts/argocd/values.yaml"
  ]
}
