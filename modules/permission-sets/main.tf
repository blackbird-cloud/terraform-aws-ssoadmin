data "aws_ssoadmin_instances" "default" {}

locals {
  instance_arn = data.aws_ssoadmin_instances.default.arns[0]
  managed_policy_attachments = flatten([
    for permission_set in var.permission_sets : [
      for policy_attachment in permission_set.policy_attachments : merge(permission_set, { policy_attachment : policy_attachment })
    ]
  ])

  customer_managed_policy_attachments = flatten([
    for permission_set in var.permission_sets : [
      for customer_managed_policy_attachment in permission_set.customer_managed_policy_attachments : merge(permission_set, { customer_managed_policy_attachment : customer_managed_policy_attachment })
    ]
  ])
}

resource "aws_ssoadmin_permission_set" "default" {
  for_each = {
    for permission_set in var.permission_sets : permission_set.name => permission_set
  }

  name             = each.key
  description      = each.value.description
  instance_arn     = local.instance_arn
  relay_state      = each.value.relay_state != "" ? each.value.relay_state : null
  session_duration = each.value.session_duration != "" ? each.value.session_duration : null
  tags             = each.value.tags != "" ? each.value.tags : null
}

resource "aws_ssoadmin_permission_set_inline_policy" "default" {
  for_each = {
    for permission_set in var.permission_sets : permission_set.name => permission_set.inline_policy if permission_set.inline_policy != ""
  }

  inline_policy      = each.value
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.default[each.key].arn
}

resource "aws_ssoadmin_managed_policy_attachment" "default" {
  for_each = {
    for managed_policy_attachment in local.managed_policy_attachments : "${managed_policy_attachment.name}-${managed_policy_attachment.policy_attachment}" => managed_policy_attachment
  }

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.default[each.value.name].arn

  managed_policy_arn = each.value.policy_attachment
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "default" {
  for_each = {
    for customer_managed_policy_attachment in local.customer_managed_policy_attachments : "${customer_managed_policy_attachment.name}-${customer_managed_policy_attachment.customer_managed_policy_attachment.path}${customer_managed_policy_attachment.customer_managed_policy_attachment.name}" => customer_managed_policy_attachment
  }
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.default[each.value.policy_set].arn


  customer_managed_policy_reference {
    name = each.value.customer_managed_policy_attachment.name
    path = each.value.customer_managed_policy_attachment.path
  }
}
