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
  peering_ip_address = module.hub.hub_firewall_private_ip
  peering_network_id = module.hub.hub_virtual_network_id
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
  peering_ip_address = module.hub.hub_firewall_private_ip
  peering_network_id = module.hub.hub_virtual_network_id
}