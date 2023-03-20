locals {
  prefix = "${var.name_prefix}-${random_uuid.this.result}"
  friendly_location = {
    "Australia Central"   = "canberra",
    "Australia East"      = "sydney",
    "Australia Southeast" = "melbourne"
  }
  subnet_functions = [ for v in var.subnet_functions: lower(v) ]
}

resource "random_uuid" "this" {}

resource "azurerm_resource_group" "this" {
  name     = "${local.prefix}-rg"
  location = var.location
  tags = {
    "location" = lookup(local.friendly_location, var.location)
  }
}

resource "azurerm_virtual_network" "this" {
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "${local.prefix}-vnet"
  address_space       = [var.address_space]
  tags = {
    "location" = lookup(local.friendly_location, var.location)
  }
}

resource "azurerm_subnet" "this" {
  for_each = toset(local.subnet_functions)
  name     = "${local.prefix}-${each.value}-subnet"
  address_prefixes = [
    cidrsubnet(azurerm_virtual_network.this.address_space[0], 2, index(local.subnet_functions, each.value))
  ]
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_virtual_network_peering" "this" {
  name                         = "${local.prefix}-peering-connection"
  resource_group_name          = azurerm_resource_group.this.name
  virtual_network_name         = azurerm_virtual_network.this.name
  remote_virtual_network_id    = var.peering_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  allow_gateway_transit = false
}

resource "azurerm_route_table" "this" {
  name                          = "${local.prefix}-route-table"
  location                      = azurerm_virtual_network.this.location
  resource_group_name           = azurerm_resource_group.this.name
  disable_bgp_route_propagation = false

  route {
    name           = "default_route"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = var.peering_ip_address
  }
}

