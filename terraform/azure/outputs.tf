output "instance_name" {
  description = "Name of the NixOS dev VM"
  value       = azurerm_linux_virtual_machine.nixos.name
}

output "instance_id" {
  description = "Azure resource ID of the NixOS dev VM"
  value       = azurerm_linux_virtual_machine.nixos.id
}

output "external_ip" {
  description = "Public IP address of the NixOS dev VM"
  value       = azurerm_public_ip.nixos.ip_address
}

output "internal_ip" {
  description = "Private IP address of the NixOS dev VM"
  value       = azurerm_linux_virtual_machine.nixos.private_ip_address
}

output "location" {
  description = "Region where the instance is deployed"
  value       = var.location
}

output "ssh_command" {
  description = "Convenience SSH command"
  value       = "ssh ${var.nixos_username}@${azurerm_public_ip.nixos.ip_address}"
}
