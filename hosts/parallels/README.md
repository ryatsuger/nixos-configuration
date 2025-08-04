# NixOS on Parallels Desktop (MacBook Pro M4)

## Initial Setup

1. **Install NixOS in Parallels Desktop**
   - Create a new VM with ARM64 Linux
   - Use the NixOS minimal ISO for aarch64
   - During installation, the installer will detect Parallels

2. **Generate Hardware Configuration**
   After installation, run:
   ```bash
   sudo nixos-generate-config --root /mnt
   ```
   
   This will create a `hardware-configuration.nix` that includes:
   - Parallels-specific settings (`hardware.parallels.enable = true`)
   - Kernel modules for Parallels Tools
   - Filesystem configuration
   - Boot device configuration

3. **Copy this configuration**
   ```bash
   # Clone your config repo
   git clone <your-repo> /tmp/nixos-config
   
   # Copy the generated hardware configuration
   cp /mnt/etc/nixos/hardware-configuration.nix /tmp/nixos-config/hosts/parallels/
   
   # Copy to the installed system
   cp -r /tmp/nixos-config /mnt/home/<username>/.config/nixos
   ```

4. **First boot and rebuild**
   ```bash
   # After first boot
   cd ~/.config/nixos
   sudo nixos-rebuild switch --flake .#parallels
   ```

## Parallels-Specific Features

- **Shared Folders**: Enabled via `prl_fs` kernel module
- **Clipboard Sharing**: Works with Parallels Tools
- **Dynamic Resolution**: Adjusts to window size
- **Coherence Mode**: Supported with X11 desktop
- **Time Sync**: Handled by Parallels Tools

## Notes

- The configuration uses `aarch64-linux` for Apple Silicon
- Higher DPI (144) is set for retina displays
- Desktop environment is included (unlike cloud configs)
- Chinese input methods are enabled for desktop use