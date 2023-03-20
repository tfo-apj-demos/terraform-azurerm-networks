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
  name     = each.value == "firewall" ? "AzureFirewallSubnet" : "${local.prefix}-${each.value}-subnet"
  address_prefixes = [
    cidrsubnet(azurerm_virtual_network.this.address_space[0], 2, index(local.subnet_functions, each.value))
  ]
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_public_ip" "this" {
  count = contains(local.subnet_functions, "firewall") ? 1 : 0
  name                = "${local.prefix}-firewall-ip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "this" {
  count = contains(local.subnet_functions, "firewall") ? 1: 0
  name                = "${local.prefix}-hub-firewall"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.this["firewall"].id
    public_ip_address_id = azurerm_public_ip.this[0].id
  }
}

resource "azurerm_virtual_network_peering" "this" {
  count = var.network_type == "spoke" ? 1 : 0
  name                         = "${local.prefix}-peering-connection"
  resource_group_name          = azurerm_resource_group.this.name
  virtual_network_name         = azurerm_virtual_network.this.name
  remote_virtual_network_id    = var.peering_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  allow_gateway_transit = false
}

resource "azurerm_route_table" "this" {
  count = var.network_type == "spoke" ? 1 : 0
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