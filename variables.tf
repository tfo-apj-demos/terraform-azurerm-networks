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

variable "peering_ip_address" {
  type = string
  default = ""
}

variable "peering_network_id" {
  type = string
  default = ""
}