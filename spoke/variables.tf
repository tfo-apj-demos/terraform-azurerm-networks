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

variable "peering_ip_address" {
  type = string
}

variable "peering_network_id" {
  type = string
}