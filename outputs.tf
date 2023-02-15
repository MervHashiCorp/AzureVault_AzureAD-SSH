output "resource_group_name" {
  value = azurerm_resource_group.adssh.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.adssh.public_ip_address
}

output "tls_private_key" {
  value     = file(tls_private_key.adssh.private_key_pem)
  sensitive = true
}