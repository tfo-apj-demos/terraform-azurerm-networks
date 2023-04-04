variable "network_type" {
  type = string
  description = "Network type, one of 'hub' or 'spoke'."
  validation {
    condition = var.network_type == "hub" || var.network_type == "spoke"
    error_message = "Value must be one of 'hub' or 'spoke'."
  }
}

variable "name_prefix" {
  type = string
}

variable "address_space" {
  type = string
}

variable "subnet_functions" {
  type = list(string)
}

variable "location" {
  type = string
}

variable "hub_rg_name" {
  type = string
  default = ""
}

variable "hub_vnet_name" {
  type = string
  default = ""
}

variable "peering_ip_address" {
  type = string
  default = ""
}

variable "peering_vnet_id" {
  type = string
  default = ""
}

variable "tags" {
  type = map(string)
}