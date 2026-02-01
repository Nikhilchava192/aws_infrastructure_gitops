resource "azurerm_virtual_network_peering" "peer01-02" {
  name = "peer-vnet01-to-vnet02"
  resource_group_name = "rg01"
  virtual_network_name = "vnet01"
  remote_virtual_network_id = azurerm_virtual_network.vnet1.id
}
resource "azurerm_virtual_network_peering" "peer02-01" {
  name = "peer-vnet02-to-vnet01"
  resource_group_name = "rg01"
  virtual_network_name = "vnet02"
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}