locals {
  common_tags = {
    business_unit = "project-name"
    provisioner   = "terraform"
    environment   = "dev"
    location      = "sri-lanka"
  }

  k8s_labels = local.common_tags
  aws_tags   = local.common_tags
}
