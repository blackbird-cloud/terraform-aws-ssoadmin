mock_provider "aws" {
  mock_data "aws_identitystore_group" {
    defaults = {
      id = "12345678-1234-1234-1234-123456789012"
    }
  }
  mock_data "aws_identitystore_user" {
    defaults = {
      id = "12345678-1234-1234-1234-123456789012"
    }
  }
  mock_data "aws_ssoadmin_instances" {
    defaults = {
      arns               = ["arn:aws:sso:::instance/ssoins-1111111111111111"]
      identity_store_ids = ["d-1234567890"]
    }
  }
}

run "permission_sets" {
  command = plan
  module {
    source = "./modules/permission-sets"
  }
  variables {
    permission_sets = [{
      name                                = "TestAdmin"
      description                         = "Test permission set"
      relay_state                         = ""
      session_duration                    = "PT8H"
      tags                                = {}
      inline_policy                       = ""
      policy_attachments                  = []
      customer_managed_policy_attachments = []
    }]
  }
}

run "account_assignments" {
  command = plan
  module {
    source = "./modules/account-assignments"
  }
  variables {
    account_assignments = [{
      account             = "123456789012"
      permission_set_name = "TestAdmin"
      permission_set_arn  = "arn:aws:sso:::permissionSet/ssoins-1111111111111111/ps-1111111111111111"
      principal_name      = "test-group"
      principal_type      = "GROUP"
    }]
  }
}
