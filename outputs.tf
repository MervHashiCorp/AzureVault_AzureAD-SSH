output "resource_group_name" {
  value = azurerm_resource_group.adssh.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.adssh.public_ip_address
}

output "tls_private_key" {
  value     = tls_private_key.adssh.private_key_pem
  sensitive = true
}

resource "local_file" "private_key" {
  content         = tls_private_key.adssh.private_key_pem
  filename        = "id_rsa"
  file_permission = "0600"
}