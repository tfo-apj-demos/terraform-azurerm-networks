# Network Deployment

This module is to assist with the accelerated deployment of a [hub and spoke network topology](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke) on Azure.

[Hub and Spoke Topology](https://miro.medium.com/v2/resize:fit:1400/format:webp/0*VrABlc5WLDHoW4Sg.png)

For each function listed in subnet functions, a subnet will be created. Because of how Azure handles certain naming conventions, a "firewall" subnet needs specific naming conventions to be applied, so part of defining the functions here is to handle the logic of that constraint.

Peering must be configured when the `network_type = "spoke"` *only*. There is conditional logic to handle bi-directional peering when the network type is spoke, that will be ignored if you attempt to pass in variables to configure this when `network_type = "hub"`.

## Example usage
```
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
```
