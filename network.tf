resource "azurerm_virtual_network" "vnet" {
  name                = "vnet01"
  address_space       = ["10.0.0.0/16"]
  location            = "southindia"
  resource_group_name = "rg01"
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet01"
  resource_group_name  = "rg01"
  virtual_network_name = "vnet01"
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet02"
  address_space       = ["10.1.0.0/16"]
  location            = "southindia"
  resource_group_name = "rg01"
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet02"
  resource_group_name  = "rg01"
  virtual_network_name = "vnet02"
  address_prefixes     = ["10.1.1.0/24"]
}