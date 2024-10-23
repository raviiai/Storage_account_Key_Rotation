terraform {
  source = "../module/automation_account"
}

inputs = {
  resource_group_name     = "Automation-Account-RG"
  location                = "southeastasia"
  automation_account_name = "Key-Rotation-AAA"
  subscription_id         = "6cbdccc8-a649-4c67-ba82-3baee2a52562"
}
