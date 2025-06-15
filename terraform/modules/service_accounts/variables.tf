variable "service_accounts" {
  description = "List of ServiceAccounts to create"
  type = list(object({
    name                            = string
    namespace                       = string
    labels                          = optional(map(string), {})
    annotations                     = optional(map(string), {})
    automount_service_account_token = optional(bool, true)
  }))

  validation {
    condition = alltrue([
      # at least one SA
      length(var.service_accounts) > 0,

      # every namespace is non-empty
      alltrue([for sa in var.service_accounts : sa.namespace != ""]),

      # names match DNS-1123 label
      alltrue([
        for sa in var.service_accounts :
        length(regexall("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", sa.name)) == 1
      ])
    ])
    error_message = <<-EOT
      Each service_accounts entry must:
        • contain at least one object
        • have a non-empty namespace
        • have a name matching DNS-1123: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$
    EOT
  }
}
