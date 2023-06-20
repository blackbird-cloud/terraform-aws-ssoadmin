locals {
  assignment_map = {
    for assignment in var.account_assignments :
    "${assignment.account}-${assignment.principal_type}-${assignment.principal_name}-${assignment.permission_set_name}" => assignment
  }
  group_list = [
    for assignment in var.account_assignments : assignment.principal_name if assignment.principal_type == "GROUP"
  ]
  user_list = [
    for assignment in var.account_assignments : assignment.principal_name if assignment.principal_type == "USER"
  ]
}

data "aws_ssoadmin_instances" "default" {}

data "aws_identitystore_group" "default" {
  for_each = toset(local.group_list)

  identity_store_id = data.aws_ssoadmin_instances.default.identity_store_ids[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.key
    }
  }
}

data "aws_identitystore_user" "default" {
  for_each = toset(local.user_list)

  identity_store_id = data.aws_ssoadmin_instances.default.identity_store_ids[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.key
    }
  }
}

resource "aws_ssoadmin_account_assignment" "default" {
  for_each = local.assignment_map

  instance_arn = data.aws_ssoadmin_instances.default.arns[0]

  principal_type = each.value.principal_type
  principal_id   = each.value.principal_type == "GROUP" ? data.aws_identitystore_group.default[each.value.principal_name].id : data.aws_identitystore_user.default[each.value.principal_name].id

  permission_set_arn = each.value.permission_set_arn

  target_id   = each.value.account
  target_type = "AWS_ACCOUNT"
}
