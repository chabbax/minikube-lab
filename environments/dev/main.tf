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
