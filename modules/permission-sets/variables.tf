variable "permission_sets" {
  type = list(object({
    name               = string
    description        = string
    relay_state        = string
    session_duration   = string
    tags               = map(string)
    inline_policy      = string
    policy_attachments = list(string)
    customer_managed_policy_attachments = list(object({
      name = string
      path = string
    }))
    permissions_boundary_attachment = object({
      name               = optional(string)
      path               = optional(string)
      managed_policy_arn = optional(string)
    })
  }))
  description = "A list of permission-sets that you would like to create."
}
