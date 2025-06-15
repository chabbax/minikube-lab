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

module "service_accounts" {
  source = "../../terraform/modules/service_accounts"

  service_accounts = [
    {
      name      = "dashboard-view-sa"
      namespace = "kubernetes-dashboard"
      labels    = { "app" = "dashboard" }
    }
  ]
}

module "cluster_role_bindings" {
  source = "../../terraform/modules/cluster_role_bindings"

  cluster_role_bindings = [
    {
      name = "dashboard-readonly-binding"
      subjects = [
        {
          kind      = "ServiceAccount"
          name      = "dashboard-view-sa"
          namespace = "kubernetes-dashboard"
          api_group = ""
        }
      ]
      role_ref = {
        api_group = "rbac.authorization.k8s.io"
        kind      = "ClusterRole"
        name      = "cluster-admin"
      }
    }
  ]
}

module "dashboard_secrets" {
  source = "../../terraform/modules/secrets"

  secrets = [
    {
      service_account_name = "dashboard-view-sa"
      namespace            = "kubernetes-dashboard"
      secret_name          = "dashboard-view-sa-token"
      labels               = { app = "dashboard" }
      annotations          = { "created-by" = "terraform" }
    }
  ]
}

module "argocd" {
  source            = "../../terraform/modules/helm_release"
  name              = "argocd"
  namespace         = "argocd"
  chart_path        = "${path.root}/../../argocd/charts/argo-cd"
  create_namespace  = true
  atomic            = true
  wait              = true
  wait_for_jobs     = true
  dependency_update = true
  timeout           = "300"
  set               = []

  values = [
    file("${path.root}/../../argocd/values/argocd-values.yaml")
  ]
}
