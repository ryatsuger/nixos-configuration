variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "koreacentral"
}

variable "resource_group_name" {
  description = "Resource group to create/use"
  type        = string
  default     = "ruiyang-nixos-dev"
}

variable "vm_name" {
  description = "Name for the NixOS dev VM"
  type        = string
  default     = "ruiyang-nixos-dev"
}

variable "vm_size" {
  description = "Azure VM size. Use an AMD nested-virt-capable size (e.g. Standard_D16ads_v5) to match the GCE n2d host with kvm-amd."
  type        = string
  default     = "Standard_D16ads_v5"
}

variable "vhd_local_path" {
  description = "Path to the locally-built fixed-size VHD (result of nix build .#nixosConfigurations.azure.config.system.build.azureImage)"
  type        = string
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB (grown from the image via growPartition/autoResize on first boot)"
  type        = number
  default     = 1000
}

variable "os_disk_type" {
  description = "OS managed disk type"
  type        = string
  default     = "Premium_LRS"
}

variable "hyper_v_generation" {
  description = "VM generation. Must match virtualisation.azureImage.vmGeneration in the NixOS host (v1 -> V1, v2 -> V2)."
  type        = string
  default     = "V1"
}

variable "nixos_username" {
  description = "Primary username on the NixOS instance (matches local.nix). The image already bakes this user + SSH key; Azure provisions the same admin user via waagent."
  type        = string
  default     = "ruiyang"
}

variable "admin_ssh_public_key" {
  description = "SSH public key for the admin user (should match the key baked into local.nix)"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "Source CIDR allowed to reach SSH (22). Lock this down to your IP."
  type        = string
  default     = "0.0.0.0/0"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
