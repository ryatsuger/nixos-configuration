# Modular NixOS Configuration

A clean, modular NixOS configuration designed for multiple machines with clear separation of concerns and cloud-ready deployments.

## 🚀 Quick Start

```bash
# Build and switch to configuration
sudo nixos-rebuild switch --flake .#<hostname>

# Available configurations:
# - parallels   (ARM64 Parallels VM on MacBook M4)
# - aws-ec2     (AWS EC2 instances)
# - gce         (Google Compute Engine)
# - nixos       (Legacy alias for GCE)
```

## 📁 Project Structure

```
.
├── flake.nix              # Flake entry point with NixOS configurations
├── flake.lock             # Pinned dependencies
│
├── hosts/                 # Machine-specific configurations
│   ├── parallels/         # MacBook M4 Parallels VM (ARM64)
│   │   ├── default.nix
│   │   ├── hardware-configuration.nix
│   │   └── README.md
│   ├── aws-ec2/           # AWS EC2 instances
│   │   └── default.nix
│   └── gce/               # Google Compute Engine
│       ├── default.nix
│       └── ssh-keys.nix
│
├── modules/               # Reusable modules
│   ├── nixos/             # System-level NixOS modules
│   │   ├── core/          # Essential system configuration
│   │   │   ├── default.nix
│   │   │   ├── locale.nix
│   │   │   ├── networking.nix
│   │   │   ├── nix.nix
│   │   │   ├── packages.nix
│   │   │   ├── ssh-keys.nix
│   │   │   └── users.nix
│   │   ├── desktop/       # Desktop environment modules
│   │   │   ├── default.nix
│   │   │   ├── fonts.nix
│   │   │   ├── i18n.nix
│   │   │   ├── x11.nix
│   │   │   └── dwm.patch
│   │   ├── services/      # System services
│   │   │   ├── docker.nix
│   │   │   ├── networking.nix
│   │   │   └── security.nix
│   │   └── options.nix    # Custom NixOS options
│   │
│   └── home/              # Home Manager modules
│       ├── default.nix
│       ├── base.nix
│       ├── shell/         # Shell environment
│       │   ├── direnv.nix
│       │   ├── git.nix
│       │   ├── ssh.nix
│       │   ├── zsh.nix
│       │   └── p10k/
│       ├── editors/       # Text editors
│       │   ├── emacs.nix
│       │   └── vscode.nix
│       ├── terminal/      # Terminal emulators
│       │   └── alacritty.nix
│       ├── desktop/       # Desktop applications
│       │   ├── browsers.nix
│       │   └── screen-lock.nix
│       └── work/          # Work-specific tools
│           ├── aws.nix
│           └── ai.nix
│
└── profiles/              # Composable machine profiles
    ├── base.nix           # Minimal system (all machines)
    ├── desktop.nix        # Full desktop environment
    └── server.nix         # Headless server configuration
```

## 🎯 Key Features

- **🧩 Modular Architecture**: Clear separation between system modules, home-manager modules, and machine-specific configs
- **🎨 Profile-Based**: Composable profiles (base, desktop, server) for different use cases
- **☁️ Cloud-Ready**: Pre-configured for AWS EC2 and Google Compute Engine
- **🏗️ Multi-Architecture**: Supports both x86_64 (cloud) and aarch64 (Apple Silicon)
- **🔒 Security First**: Fail2ban, firewall rules, SSH hardening, and kernel security options
- **🌏 International**: Full CJK (Chinese, Japanese, Korean) language support with fcitx5
- **🎛️ Single Toggle**: Control GUI features with `mySystem.enableDesktop` option

## 💻 Supported Platforms

### Parallels Desktop (MacBook Pro M4)
- **Architecture**: ARM64/aarch64
- **Features**: Full desktop environment, Parallels Tools integration
- **Display**: Optimized for Retina displays (144 DPI)
- **Use Case**: Local development on Apple Silicon

### AWS EC2
- **Architecture**: x86_64
- **Features**: AWS Systems Manager, enhanced networking
- **Security**: Cloud firewall, SSM session manager support
- **Use Case**: Cloud development and production servers

### Google Compute Engine
- **Architecture**: x86_64  
- **Features**: GCE guest agent, cloud logging
- **Security**: Cloud firewall (local firewall disabled)
- **Use Case**: Google Cloud workloads

## 🛠️ Configuration Guide

### Adding a New Machine

1. Create a directory under `hosts/`:
   ```bash
   mkdir -p hosts/my-machine
   ```

2. Create `hosts/my-machine/default.nix`:
   ```nix
   { config, lib, pkgs, ... }:
   {
     imports = [
       ./hardware-configuration.nix  # Generate with nixos-generate-config
       ../../profiles/desktop.nix     # Or server.nix
     ];
     
     networking.hostName = "my-machine";
     # Add machine-specific config here
   }
   ```

3. Add to `flake.nix`:
   ```nix
   nixosConfigurations = {
     my-machine = nixpkgs.lib.nixosSystem {
       system = "x86_64-linux";  # or "aarch64-linux"
       specialArgs = { inherit inputs; };
       modules = [
         ./hosts/my-machine/default.nix
         home-manager.nixosModules.home-manager
         homeManagerConfig
       ];
     };
   };
   ```

### SSH Key Management

Configure SSH keys in `hosts/<machine>/ssh-keys.nix`:

```nix
{
  mySystem.ssh.authorizedKeys = [
    "ssh-ed25519 AAAAC3... user@host"
  ];
  
  mySystem.ssh.knownHosts = {
    "github.com" = {
      hostNames = [ "github.com" ];
      publicKey = "ssh-ed25519 AAAAC3...";
    };
  };
}
```

### Custom Options

The configuration provides custom options under `mySystem`:

- `mySystem.enableDesktop`: Enable/disable all GUI features
- `mySystem.username`: Primary username (default: "nixos")
- `mySystem.userFullName`: User's full name (default: "NixOS User")
- `mySystem.userEmail`: User's email address (default: "user@example.com")
- `mySystem.ssh.authorizedKeys`: Manage SSH public keys
- `mySystem.ssh.knownHosts`: Pre-configure SSH known hosts

### Local Configuration

Each host can have a `local.nix` file for machine-specific settings that shouldn't be tracked in git:

1. Copy the template:
   ```bash
   cp local.nix.example hosts/<machine>/local.nix
   ```

2. Edit `hosts/<machine>/local.nix`:
   ```nix
   {
     mySystem = {
       username = "alice";
       userFullName = "Alice Smith";
       userEmail = "alice@example.com";
     };
     
     mySystem.ssh.authorizedKeys = [
       "ssh-ed25519 AAAAC3... alice@laptop"
     ];
   }
   ```

The `local.nix` file is automatically imported if it exists and is ignored by git.

### Changing the Username

To use a different username, create a `local.nix` file in your host directory:

```nix
# hosts/my-machine/local.nix
{
  mySystem.username = "alice";
  mySystem.userFullName = "Alice Smith";
  mySystem.userEmail = "alice@example.com";
}
```

This will:
- Create the user with the specified username
- Configure home-manager for that user
- Update git configuration with the user's name and email
- Set proper ownership for SSH configurations

## 📦 Module Categories

### Core Modules (`modules/nixos/core/`)
Essential system configuration that all machines need:
- Nix daemon settings and garbage collection
- Networking, DNS, and firewall rules
- User accounts and groups
- Base system packages
- Locale and timezone
- SSH key management

### Desktop Modules (`modules/nixos/desktop/`)
GUI and desktop environment (only loaded when `mySystem.enableDesktop = true`):
- X11 with DWM window manager
- Font configuration (including CJK fonts)
- Input methods (fcitx5 with Chinese support)
- Audio (PipeWire)
- Common desktop packages

### Service Modules (`modules/nixos/services/`)
System services and daemons:
- Docker with auto-prune
- OpenSSH with hardened settings
- Tailscale VPN
- Security (fail2ban, AppArmor, GnuPG)
- VNC server (TigerVNC with secure defaults)

### Home Manager Modules (`modules/home/`)
User-specific configuration:
- Shell environment (Zsh with Powerlevel10k)
- Development tools (Git, direnv)
- Text editors (Emacs, VS Code)
- Terminal emulator (Alacritty)
- Work tools (AWS CLI profiles)

## 🖥️ VNC Remote Desktop

### Enable VNC Server
Add to your machine configuration:
```nix
services.vncServer = {
  enable = true;
  localhostOnly = true;  # Secure by default (SSH tunnel required)
  # openFirewall = true; # Only if direct access needed
};
```

### Quick Setup for GCE
```bash
# Use the provided setup script
./scripts/gce-vnc-setup.sh [instance-name] [zone] [machine-type] [disk-size]

# Or manually:
# 1. Create instance with VNC tag
gcloud compute instances create nixos-vnc \
  --image-family=nixos-25-05 \
  --image-project=nixos-cloud \
  --machine-type=e2-medium \
  --zone=us-central1-a \
  --tags=vnc-server

# 2. Create firewall rule
gcloud compute firewall-rules create allow-vnc \
  --allow tcp:5901 \
  --source-ranges 0.0.0.0/0 \
  --target-tags vnc-server

# 3. Get external IP and connect
gcloud compute instances describe nixos-vnc \
  --zone=us-central1-a \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

### Connect via SSH Tunnel (Recommended)
```bash
# Create SSH tunnel
ssh -L 5901:localhost:5901 user@remote-host

# Connect VNC viewer to
localhost:5901  # Port is always 5900 + display number
```

### Security Notes
- VNC is configured with `localhostOnly = true` by default (secure)
- ⚠️ **GCE configuration allows PUBLIC INTERNET ACCESS** - use with caution!
- Strong password authentication (20-char auto-generated on GCE)
- **Strongly recommended**: Use SSH tunneling or VPN instead of direct access
- To view password on GCE: `sudo cat /etc/vnc-password`
- Password files are created with 600 permissions (only readable by owner)
- Setup script offers IP-restricted firewall rules for better security

## 🔧 Maintenance

### Update Dependencies
```bash
# Update flake inputs
nix flake update

# Update specific input
nix flake update nixpkgs
```

### Check Configuration
```bash
# Validate all configurations
nix flake check

# Build without switching
sudo nixos-rebuild build --flake .#<hostname>
```

### Clean Up
```bash
# Garbage collect old generations
sudo nix-collect-garbage -d

# Remove specific generation
sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations <number>
```

## 🤝 Contributing

1. Follow the existing module structure
2. Use `lib.mkDefault` for overrideable options
3. Document any new options in `modules/nixos/options.nix`
4. Test changes with `nix flake check`

## 📝 License

This configuration is provided as-is for personal use. Feel free to adapt it for your needs.

## 🙏 Acknowledgments

Built with NixOS 25.05 and the amazing Nix community tools:
- [NixOS](https://nixos.org/)
- [Home Manager](https://github.com/nix-community/home-manager)
- [nixpkgs](https://github.com/NixOS/nixpkgs)