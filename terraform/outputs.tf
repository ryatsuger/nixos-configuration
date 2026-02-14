output "instance_name" {
  description = "Name of the NixOS dev VM instance"
  value       = google_compute_instance.nixos_dev.name
}

output "instance_id" {
  description = "Instance ID of the NixOS dev VM"
  value       = google_compute_instance.nixos_dev.instance_id
}

output "external_ip" {
  description = "External IP address of the NixOS dev VM"
  value       = google_compute_instance.nixos_dev.network_interface[0].access_config[0].nat_ip
}

output "internal_ip" {
  description = "Internal IP address of the NixOS dev VM"
  value       = google_compute_instance.nixos_dev.network_interface[0].network_ip
}

output "zone" {
  description = "Zone where the instance is deployed"
  value       = var.zone
}
