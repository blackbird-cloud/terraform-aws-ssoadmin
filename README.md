<!-- BEGIN_TF_DOCS -->
# AWS IAM Identity Center (SSO Admin) Terraform module
A Terraform module which helps you assign permissions-sets to users and groups. Read [this](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html) page for more information.

[![blackbird-logo](https://raw.githubusercontent.com/blackbird-cloud/terraform-module-template/main/.config/logo_simple.png)](https://blackbird.cloud)

## Example
```hcl
module "users" {
  source  = "blackbird-cloud/identitystore/aws//modules/users"
  version = "~> 1"
  users = [
    {
      email       = "john.doe@email.com"
      user_name   = "john.doe@email.com"
      given_name  = "John"
      family_name = "Doe"
    },
    {
      email       = "jane.doe@email.com"
      user_name   = "jane.doe@email.com"
      given_name  = "Jane"
      family_name = "doe"
    }
  ]
}

module "groups" {
  source  = "blackbird-cloud/identitystore/aws//modules/groups"
  version = "~> 1"
  groups = [
    {
      display_name = "Administrators"
      description  = "The Administrators group."
      members = [
        module.users.users["john.doe@email.com"].user_id,
        module.users.users["jane.doe@email.com"].user_id
      ]
    }
  ]
}


module "permission_sets" {
  source  = "blackbird-cloud/ssoadmin/aws//modules/permission-sets"
  version = "~> 1"

  permission_sets = [
    {
      name                                = "AdministratorAccess",
      description                         = "AdministratorAccess",
      relay_state                         = "",
      session_duration                    = "PT8H",
      tags                                = {},
      inline_policy                       = "",
      customer_managed_policy_attachments = [],
      policy_attachments                  = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    },
  ]
}

data "aws_caller_identity" "current" {}

module "account_assignments" {
  source  = "blackbird-cloud/ssoadmin/aws//modules/account-assignments"
  version = "~> 1"

  account_assignments = [
    {
      account             = data.aws_caller_identity.current.account_id
      principal_type      = "GROUP"
      principal_name      = module.groups.groups.Administrators.display_name
      permission_set_arn  = module.permission_sets.permission_sets.AdministratorAccess.arn
      permission_set_name = module.permission_sets.permission_sets.AdministratorAccess.name
    }
  ]
}
```
<!-- BEGIN_TF_DOCS -->
## Permission sets
A Terraform module which helps you create permissions-sets. Read [this](https://docs.aws.amazon.com/singlesignon/latest/userguide/permissionsetsconcept.html) page for more information.

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5 |

### Resources

| Name | Type |
|------|------|
| [aws_ssoadmin_customer_managed_policy_attachment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_customer_managed_policy_attachment) | resource |
| [aws_ssoadmin_managed_policy_attachment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_permission_set_inline_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set_inline_policy) | resource |
| [aws_ssoadmin_instances.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_permission_sets"></a> [permission\_sets](#input\_permission\_sets) | A list of permission-sets that you would like to create. | <pre>list(object({<br>    name               = string<br>    description        = string<br>    relay_state        = string<br>    session_duration   = string<br>    tags               = map(string)<br>    inline_policy      = string<br>    policy_attachments = list(string)<br>    customer_managed_policy_attachments = list(object({<br>      name = string<br>      path = string<br>    }))<br>  }))</pre> | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_permission_sets"></a> [permission\_sets](#output\_permission\_sets) | The created permission-sets |
<!-- END_TF_DOCS -->

<!-- BEGIN_TF_DOCS -->
## Account assignments
A Terraform module which helps you assign permissions-sets to users and groups. Read [this](https://docs.aws.amazon.com/singlesignon/latest/userguide/useraccess.html) page for more information.

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5 |

### Resources

| Name | Type |
|------|------|
| [aws_ssoadmin_account_assignment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_identitystore_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_identitystore_user.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_user) | data source |
| [aws_ssoadmin_instances.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_assignments"></a> [account\_assignments](#input\_account\_assignments) | A list of account assignments to create. | <pre>list(object({<br>    account             = string<br>    permission_set_name = string<br>    permission_set_arn  = string<br>    principal_name      = string<br>    principal_type      = string<br>  }))</pre> | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_assignments"></a> [assignments](#output\_assignments) | The created account assignments. |
<!-- END_TF_DOCS -->

## About

We are [Blackbird Cloud](https://blackbird.cloud), Amsterdam based cloud consultancy, and cloud management service provider. We help companies build secure, cost efficient, and scale-able solutions.

Checkout our other :point\_right: [terraform modules](https://registry.terraform.io/namespaces/blackbird-cloud)

## Copyright

Copyright © 2017-2023 [Blackbird Cloud](https://blackbird.cloud)
<!-- END_TF_DOCS -->