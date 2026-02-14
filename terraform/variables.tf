variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "asia-northeast3"
}

variable "zone" {
  description = "The GCP zone for the VM"
  type        = string
  default     = "asia-northeast3-a"
}

variable "vm_name" {
  description = "Name for the NixOS dev VM"
  type        = string
  default     = "ruiyang-nixos-dev"
}

variable "machine_type" {
  description = "Machine type for the VM"
  type        = string
  default     = "n2d-standard-16"
}

variable "boot_disk_image_source" {
  description = "GCS URL of the NixOS image to import"
  type        = string
  default     = "https://storage.googleapis.com/suger-gce-images/nixos-image-google-compute-25.11.20251209.09eb77e-x86_64-linux.raw.tar.gz"
}

variable "boot_disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 1000
}

variable "boot_disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "pd-ssd"
}

variable "nixos_config_repo" {
  description = "Git URL of the NixOS flake configuration repository"
  type        = string
  default     = "https://github.com/ryatsuger/nixos-configuration"
}

variable "nixos_config_flake" {
  description = "Flake configuration name to use with nixos-rebuild"
  type        = string
  default     = "gce"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
