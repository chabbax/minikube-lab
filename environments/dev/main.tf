module "namespaces" {
  source = "../../terraform/modules/namespaces"

  default_labels = local.k8s_labels

  namespaces = [
    {
      name        = "dev-namespace"
      labels      = { overide_lable = "test" }
      annotations = { owner = "example" }
    },
    {
      name        = "stag-namespace"
      annotations = { owner = "example" }
    },
    {
      name = "prod-namespace"
    }
  ]
}
