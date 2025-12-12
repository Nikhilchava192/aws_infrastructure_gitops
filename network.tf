resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet
  address_space       = var.ipaddress
  location            = var.location
  resource_group_name = var.rg
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet
  resource_group_name  = var.rg
  virtual_network_name = var.vnet
  address_prefixes     = ["10.0.1.0/24"]
}