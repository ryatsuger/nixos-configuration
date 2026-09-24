{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    # Azure image module (provides waagent, cloud-init, Hyper-V modules,
    # ttyS0 serial console and a fixed-size VHD build target).
    "${modulesPath}/virtualisation/azure-image.nix"

    # Desktop profile: brings the full GUI app set + fonts + config so the
    # VNC session (Xvnc :1) has a real desktop. The physical X server it
    # would normally start is suppressed below — see headless note.
    ../../profiles/desktop.nix

    ../../local.nix
  ];

  # Docker for in-VM container workloads (dev/build host).
  virtualisation.docker.enable = true;

  # 2 TiB Premium SSD (P40) data disk, Azure LUN 0. Hot-added to the running
  # VM, so no reboot was needed; this entry is what makes it come back after
  # one. Formatted ext4 on the whole device (no partition table) so it can be
  # grown live: expand the disk in Azure, rescan the SCSI device, then
  # resize2fs — there is no partition to extend first.
  # `nofail` so the host still boots if the disk is ever detached.
  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/2241c1f0-90bf-41ae-8ead-9b42e334c802";
    fsType = "ext4";
    options = [ "defaults" "noatime" "nofail" ];
  };

  # The boot loader must name the disk that holds the root filesystem.
  # `azure-image.nix` hardcodes `/dev/sda` for a Gen 1 (BIOS) VM, which was the
  # OS disk until the data disk above enumerated as `sda` and displaced root to
  # `sdb`. A rebuild then tries to embed GRUB in the data disk - whole-device
  # ext4, no partition table - and fails with "embedding is not possible".
  #
  # `/dev/disk/azure/root` is Azure's own symlink for the OS disk and follows it
  # across enumeration changes. A bare `/dev/sdb` would reintroduce the same
  # fault the next time a disk is attached. It names the DISK rather than
  # `root-part1`, because the boot record lives on the disk.
  #
  # `mkForce` because the imported module assigns the option directly.
  boot.loader.grub.device = lib.mkForce "/dev/disk/azure/root";

  # Network configuration.
  # azure-common.nix sets hostName = mkDefault ""; override it so that
  # system.autoUpgrade (which builds .#${config.networking.hostName}) and
  # the `azure` flake output agree.
  networking.hostName = "azure";
  networking.enableIPv6 = false;

  # cloud-init's update_hostname module pulls the Azure VM name from
  # metadata on every boot and overrides networking.hostName as the
  # transient hostname. Tell it to leave the hostname alone.
  services.cloud-init.settings.preserve_hostname = true;
  mySystem.headless = true;

  # Headless cloud VM: there is no physical GPU/monitor, so the X server +
  # login manager that the desktop profile (x11.nix) would start have
  # nothing to attach to. The VNC server's Xvnc :1 provides the display
  # instead, so force the physical X stack off.
  services.xserver.enable = lib.mkForce false;
  services.displayManager.ly.enable = lib.mkForce false;

  # The desktop profile enables NetworkManager (for a desktop wifi applet),
  # but Azure's networking is managed by cloud-init/systemd-networkd. Letting
  # NM take over the interface risks dropping the VM off the network. Force
  # it off — networking on this host stays as the azure-image module set it.
  networking.networkmanager.enable = lib.mkForce false;

  # Headless VNC server, localhost-only — reach it over an SSH tunnel:
  #   ssh -N -L 5901:localhost:5901 ruiyang@<host> ; then vncviewer localhost:5901
  # See modules/nixos/services/vnc.nix for the one-time vncpasswd setup.
  mySystem.vnc.enable = true;

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

  # Host firewall: default-deny inbound, allow ONLY SSH (22). The Azure NSG
  # was not actually filtering (the VM was compromised via an exposed DB port),
  # so protect the host at the in-VM firewall. Outbound is unrestricted;
  # loopback and established/related connections are always accepted.
  # NOTE: Docker-published ports bypass this INPUT filter — always bind
  # containers to 127.0.0.1 (never publish on 0.0.0.0) or they re-expose.
  networking.firewall = {
    enable = lib.mkForce true;
    allowedTCPPorts = lib.mkForce [ 22 ];
    allowedUDPPorts = lib.mkForce [ ];
    allowedTCPPortRanges = lib.mkForce [ ];
    allowedUDPPortRanges = lib.mkForce [ ];
  };

  # Azure CLI for in-VM management.
  environment.systemPackages = with pkgs; [
    azure-cli
  ];

  # azure-common.nix already sets this, but keep it explicit alongside the
  # other cloud hosts.
  services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";
}
