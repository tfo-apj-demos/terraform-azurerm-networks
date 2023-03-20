output "subnet_ids" {
  value = { for v in azurerm_subnet.this: v.name => v.id }
}