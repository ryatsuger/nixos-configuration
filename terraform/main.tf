terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.6"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Import NixOS image from GCS
resource "google_compute_image" "nixos" {
  name   = "nixos-25-11-dev"
  family = "nixos"

  raw_disk {
    source = var.boot_disk_image_source
  }

  guest_os_features {
    type = "VIRTIO_SCSI_MULTIQUEUE"
  }

  guest_os_features {
    type = "UEFI_COMPATIBLE"
  }

  guest_os_features {
    type = "GVNIC"
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [name]
  }
}

# NixOS dev instance
resource "google_compute_instance" "nixos_dev" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = google_compute_image.nixos.self_link
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network = "default"

    # Assign external IP
    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    enable-oslogin = "FALSE"
  }

  metadata_startup_script = <<-EOF
#!/bin/sh
set -e
export PATH=/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH
exec > /var/log/startup-script.log 2>&1

echo "Starting NixOS dev instance setup at $(date)"

# 1. Clone the config repo
echo "Cloning NixOS configuration from ${var.nixos_config_repo}..."
if [ -d /etc/nixos/flake-config ]; then
  echo "Config directory already exists, pulling latest..."
  nix shell nixpkgs#git -c git -C /etc/nixos/flake-config pull
else
  nix shell nixpkgs#git -c git clone ${var.nixos_config_repo} /etc/nixos/flake-config
fi

# 2. Rebuild with the flake configuration
echo "Running nixos-rebuild switch --flake /etc/nixos/flake-config#${var.nixos_config_flake}..."
nixos-rebuild switch --flake /etc/nixos/flake-config#${var.nixos_config_flake} || {
  echo "ERROR: nixos-rebuild failed"
  exit 1
}

echo "NixOS dev instance setup completed at $(date)"
EOF

  labels = {
    environment = var.environment
    purpose     = "nixos-dev"
    managed_by  = "terraform"
  }

  scheduling {
    preemptible         = false
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  lifecycle {
    create_before_destroy = true
  }
}
