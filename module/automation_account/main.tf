resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
}

resource "azurerm_automation_account" "automation_account" {
  name                = var.automation_account_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }
}


data "local_file" "example" {
  filename = "${path.module}/key_rotation.ps1"
}


resource "azurerm_automation_runbook" "example" {
  name                    = var.runbook_name
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.automation_account.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This is an example runbook"
  runbook_type            = "PowerShell"

  content    = data.local_file.example.content
  depends_on = [azurerm_automation_account.automation_account]
}


data "azurerm_subscription" "primary" {
}

resource "azurerm_role_assignment" "automation_role_assignment" {
  principal_id         = azurerm_automation_account.automation_account.identity[0].principal_id
  role_definition_name = "Storage Account Key Operator Service Role"    # Classic Storage Account Key Operator Service Role
  scope                = data.azurerm_subscription.primary.id
}
