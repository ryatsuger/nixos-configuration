# NixOS on VMware Fusion (Apple Silicon Mac)

## Initial Setup

1. **Install NixOS in VMware Fusion**
   - Create a new VM with Linux > Other Linux 6.x kernel 64-bit ARM
   - Use the NixOS minimal ISO for aarch64
   - Allocate appropriate resources (recommended: 4+ GB RAM, 40+ GB disk)
   - Enable virtualization features in VM settings

2. **Generate Hardware Configuration**
   After installation, run:
   ```bash
   sudo nixos-generate-config --root /mnt
   ```
   
   This will create a `hardware-configuration.nix` that includes:
   - VMware-specific kernel modules
   - Filesystem configuration (BTRFS with compression)
   - Boot device configuration
   - Swap configuration

3. **Copy this configuration**
   ```bash
   # Clone your config repo
   git clone <your-repo> /tmp/nixos-config
   
   # Copy the generated hardware configuration
   cp /mnt/etc/nixos/hardware-configuration.nix /tmp/nixos-config/hosts/vmware/
   
   # Copy to the installed system
   cp -r /tmp/nixos-config /mnt/home/<username>/.config/nixos
   ```

4. **First boot and rebuild**
   ```bash
   # After first boot
   cd ~/.config/nixos
   sudo nixos-rebuild switch --flake .#vmware
   ```

## VMware-Specific Features

### Shared Folders
- **Auto-mount**: Shared folders are automatically mounted at `/mnt/hgfs`
- **User Access**: A symlink is created at `~/VMShared` for easy access
- **Configuration**: Add shared folders in VMware Fusion settings
- **List shares**: Run `vmware-hgfsclient` to see available shared folders

### VMware Tools
- **open-vm-tools**: Automatically installed and enabled
- **Services**: Handles time sync, resolution changes, and guest-host integration
- **Clipboard**: Copy/paste between host and guest (requires X11)

### Networking
- **systemd-networkd**: Used instead of NetworkManager for better VMware compatibility
- **DHCP**: Configured for all ethernet interfaces
- **DNS**: Uses systemd-resolved with Cloudflare (1.1.1.1) and Google (8.8.8.8) DNS

## Filesystem Layout

The configuration uses BTRFS with multiple subvolumes:
- `/` - Root filesystem
- `/boot` - EFI boot partition (FAT32)
- `/nix/store` - Nix store with zstd compression
- `/var/lib/docker` - Docker storage with zstd compression
- `/home` - User home directories

## Performance Optimizations

- **BTRFS Compression**: `zstd` compression on store and docker volumes
- **noatime**: Disabled access time updates for better performance
- **DPI**: Set to 144 for retina displays

## Troubleshooting

### Shared Folders Not Visible
```bash
# Check if VMware tools are running
systemctl status vmware-guest.service

# List available shares
vmware-hgfsclient

# Manually mount shared folders
sudo mount -t fuse.vmhgfs-fuse .host:/ /mnt/hgfs
```

### Resolution Issues
```bash
# Restart VMware tools
sudo systemctl restart vmware-guest.service
```

### Network Issues
```bash
# Check systemd-resolved status
systemctl status systemd-resolved

# Test DNS resolution
resolvectl query google.com

# Restart networking
sudo systemctl restart systemd-networkd
```

## Notes

- The configuration uses `aarch64-linux` for Apple Silicon Macs
- Desktop environment with Chinese input methods included
- SSH is enabled by default on port 22
- Development ports 3000-9000 are open in the firewall