## CREATE RESOURCE GROUP
resource "azurerm_resource_group" "tfstate_resource_group" {
  name      = var.tfstate_resource_group
  location  = var.tfstate_location
  tags      = local.resource_tags
}

## CREATE STORAGE ACCOUNT
resource "azurerm_storage_account" "tfstate_storage_account" {

  depends_on = [ azurerm_resource_group.tfstate_resource_group ]

  name                     = var.tfstate_storage_account_name
  resource_group_name      = azurerm_resource_group.tfstate_resource_group.name
  location                 = azurerm_resource_group.tfstate_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  
  timeouts {
    create = "15m"
    delete = "30m"
    read   = "10m"
  }

  tags                     = local.resource_tags
}

## CREATE STORAGE CONTAINER
resource "azurerm_storage_container" "tfstate_storage_container" {

  depends_on = [ azurerm_storage_account.tfstate_storage_account ]

  name                  = var.tfstate_storage_container
  storage_account_name  = azurerm_storage_account.tfstate_storage_account.name
  container_access_type = "private"
}

data "azuread_client_config" "current" {}

data "azuread_user" "current" {
  object_id = data.azuread_client_config.current.object_id
}
