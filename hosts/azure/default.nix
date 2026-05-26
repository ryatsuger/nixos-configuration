{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    # Azure image module (provides waagent, cloud-init, Hyper-V modules,
    # ttyS0 serial console and a fixed-size VHD build target).
    "${modulesPath}/virtualisation/azure-image.nix"

    # Desktop profile (mirrors the GCE dev host). Swap for
    # ../../profiles/server.nix if you want a headless server build.
    ../../profiles/desktop.nix

    ../../local.nix
  ];

  # Network configuration.
  # azure-common.nix sets hostName = mkDefault ""; override it so that
  # system.autoUpgrade (which builds .#${config.networking.hostName}) and
  # the `azure` flake output agree.
  networking.hostName = "azure";
  networking.enableIPv6 = false;
  mySystem.headless = true;

  # VHD generation. v1 = legacy BIOS (simplest). Use "v2" for a Gen2
  # (UEFI) VM — note Secure Boot must be disabled at creation time.
  virtualisation.azureImage.vmGeneration = "v1";

  # Accelerated networking: enable only if the chosen VM size supports it
  # and you enable it on the NIC in Terraform.
  # virtualisation.azure.acceleratedNetworking = true;

  # KVM nested virtualization (matches the GCE host). Only works on Azure
  # VM sizes that support nested virt (e.g. Dadsv5/Dasv5). Drop this line
  # if you don't need it or pick a size without nested-virt support.
  boot.kernelModules = [ "kvm-amd" ];

  # Azure handles inbound filtering at the NSG layer; keep the in-VM
  # firewall off to match the GCE host's behavior.
  networking.firewall.enable = lib.mkForce false;

  # Azure CLI for in-VM management.
  environment.systemPackages = with pkgs; [
    azure-cli
  ];

  # azure-common.nix already sets this, but keep it explicit alongside the
  # other cloud hosts.
  services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";
}
