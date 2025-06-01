# Install from local path (air‐gapped) using chart_pat
# Install from a remote repository by leaving chart_path="" and set chart + repository + version.

module "argocd" {
  source            = "../../terraform/modules/helm_release"
  name              = "argocd"
  namespace         = "argocd"
  chart_path        = "${path.root}/../../terraform/helm/charts/argo-cd"
  create_namespace  = true
  atomic            = true
  wait              = true
  wait_for_jobs     = true
  dependency_update = true
  timeout           = "5m"
  set               = []

  values = [
    "${path.root}/helm-values/argocd-values.yaml"
  ]
}
