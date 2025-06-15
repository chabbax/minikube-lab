variable "secrets" {
  description = <<-EOT
    List of ServiceAccount-token Secrets to create. Each item must include:
      • service_account_name (string) – the SA you’re binding to
      • namespace            (string) – where both SA & Secret live
      • secret_name          (string) – name you want for the Secret
      • labels               (map(string), optional)
      • annotations          (map(string), optional)
  EOT

  type = list(object({
    service_account_name = string
    namespace            = string
    secret_name          = string
    labels               = optional(map(string), {})
    annotations          = optional(map(string), {})
  }))
  default = []
}
