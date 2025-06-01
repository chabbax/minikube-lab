module "namespaces" {
  source = "../../terraform/modules/namespaces"

  default_labels = local.k8s_labels

  namespaces = [
    {
      name        = "apps"
      labels      = { overide_lable = "test" }
      annotations = { owner = "example" }
    },
    {
      name        = "monitoring"
      annotations = { owner = "example" }
    },
    {
      name = "ops"
    }
  ]
}

module "nginx-example-deployment" {
  source = "../../terraform/modules/deployments"

  deployments = [
    {
      manifest = "../../terraform/kubernetes/deployment.yaml"
    }
  ]
}

module "nginx-example-services" {
  source = "../../terraform/modules/services"

  services = [
    {
      manifest = "../../terraform/kubernetes/service.yaml"
    }
  ]
}

module "taints" {
  source = "../../terraform/modules/taints"

  taints = [
    {
      node_name = "minikube"
      key       = "control-plane"
      value     = "system"
      effect    = "NoSchedule"
    },
    {
      node_name = "minikube-m02"
      key       = "apps"
      value     = "nginx"
      effect    = "NoSchedule"
    }
  ]
}

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
  timeout           = "300"
  set               = []

  values = [
    file("${path.root}/helm-values/argocd-values.yaml")
  ]
}
