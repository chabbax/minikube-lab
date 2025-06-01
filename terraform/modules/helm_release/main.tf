/*
  @params name             - Helm release name (must be unique per namespace)
  @params namespace        - Kubernetes namespace in which to install the release
  @params chart_path       - Local filesystem path to an unpacked Helm chart (if non-empty, used instead of chart+repository)
  @params chart            - Name of the remote chart (ignored if chart_path is non-empty)
  @params repository       - URL of the Helm chart repository (ignored if chart_path is non-empty)
  @params version          - Chart version to install (only used when chart_path == "")
  @params create_namespace - If true, auto-create the target namespace
  @params atomic           - If true, automatically roll back on failure
  @params wait             - If true, wait until all pods/CRDs/etc. are ready
  @params wait_for_jobs    - If true, wait for Kubernetes Jobs to complete before finishing
  @params dependency_update- If true, run `helm dependency update` before install/upgrade
  @params timeout          - How long to wait for the Helm operation (e.g. "5m")
  @params values           - List of file paths to YAML values files that override chart defaults
  @params set              - List of individual "key=value" overrides for helm --set

  @note   Installs from local path if provided for air gapped environments; otherwise uses remote chart and repository
  @note   Installs from local path (air‐gapped) using chart_pat
  @note   Install from a remote repository by leaving chart_path="" and set chart + repository + version.
*/
resource "helm_release" "release" {
  name      = var.name
  namespace = var.namespace

  chart      = length(trimspace(var.chart_path)) > 0 ? var.chart_path : var.chart
  repository = length(trimspace(var.chart_path)) == 0 ? var.repository : null
  version    = (length(trimspace(var.chart_path)) == 0 && length(trimspace(var.chart_version)) > 0) ? var.chart_version : null

  create_namespace  = var.create_namespace
  atomic            = var.atomic
  wait              = var.wait
  wait_for_jobs     = var.wait_for_jobs
  dependency_update = var.dependency_update
  timeout           = var.timeout

  values = var.values

  dynamic "set" {
    for_each = var.set
    content {
      name  = split("=", set.value)[0]
      value = split("=", set.value)[1]
    }
  }
}
