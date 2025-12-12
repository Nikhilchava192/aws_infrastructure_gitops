resource "azurerm_resource_group" "rg" {
  name = var.rg
  location = var.location
}

resource "azurerm_storage_account" "name" {
  name = "stroge01"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.location
  account_tier = "Standard"
  account_replication_type = "LRS"
  tags = {
    environment = "dev"
  }
}
resource "azurerm_storage_container" "name" {
  name = "vhds"
  storage_account_id = azurerm_storage_account.name.id
  container_access_type = "blob"
}