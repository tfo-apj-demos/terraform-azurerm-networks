module "hub" {
  source = "../"

  location = "Australia Central"

  network_type = "hub"
  name_prefix = "hub"
  address_space = "10.0.0.0/24"
  subnet_functions = [
    "Firewall",
    "Management",
    "Gateway"
  ]
  tags = {
    "DoNotDelete" = "true"
    "owner" = "go"
  }
}

module "spoke_sydney" {
  source = "../"

  network_type = "spoke"
  name_prefix = "sydney"
  address_space = "10.0.1.0/24"
  subnet_functions = [
    "workload"
  ]
  location = "Australia East"
  hub_rg_name = module.hub.management_resource_group_name
  hub_vnet_name = module.hub.hub_virtual_network_name
  peering_ip_address = module.hub.hub_firewall_private_ip
  peering_vnet_id = module.hub.hub_virtual_network_id
  tags = {
    "DoNotDelete" = "true"
    "owner" = "go"
  }
}

module "spoke_melbourne" {
  source = "../"

  network_type = "spoke"
  name_prefix = "melbourne"
  address_space = "10.0.2.0/24"
  subnet_functions = [
    "workload"
  ]
  location = "Australia Southeast"
  hub_rg_name = module.hub.management_resource_group_name
  hub_vnet_name = module.hub.hub_virtual_network_name
  peering_ip_address = module.hub.hub_firewall_private_ip
  peering_vnet_id = module.hub.hub_virtual_network_id
  tags = {
    "DoNotDelete" = "true"
    "owner" = "go"
  }
}