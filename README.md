# Network Deployment

This module is to assist with the accelerated deployment of a [hub and spoke network topology](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke) on Azure.

[Hub and Spoke Topology](https://miro.medium.com/v2/resize:fit:1400/format:webp/0*VrABlc5WLDHoW4Sg.png)

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
```
