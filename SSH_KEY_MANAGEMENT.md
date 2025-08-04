# SSH Key Management in NixOS

This guide covers different strategies for managing SSH keys in your NixOS configuration.

## 1. Public Keys (Authorized Keys)

### Basic Configuration

Add authorized SSH public keys in your host configuration:

```nix
# hosts/gce/default.nix
{
  mySystem.ssh.authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG... user@laptop"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ... user@desktop"
  ];
}
```

### Using SSH Key Files

For better organization, create a separate file:

```nix
# hosts/common/ssh-keys.nix
{
  mySystem.ssh.authorizedKeys = [
    # Personal devices
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG... user@macbook"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH... user@desktop"
    
    # Work devices
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ... user@work-laptop"
    
    # Emergency access
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK... user@phone"
  ];
}
```

Then import it in your hosts:

```nix
# hosts/gce/default.nix
{
  imports = [
    ../common/ssh-keys.nix
  ];
}
```

## 2. Private Keys Management

### Option 1: 1Password SSH Agent (Recommended)

If you're using 1Password, it can manage your SSH keys securely:

```nix
# Already configured in modules/home/shell/ssh.nix
# Keys are stored in 1Password and accessed via agent
```

Enable 1Password SSH agent in 1Password settings, and your keys will be available automatically.

### Option 2: Encrypted Secrets with agenix/sops-nix

Install agenix for encrypted secrets:

```nix
# flake.nix
{
  inputs = {
    agenix.url = "github:ryantm/agenix";
  };
}
```

Create encrypted SSH keys:

```bash
# Create age key for encryption
age-keygen -o ~/.config/age/keys.txt

# Encrypt your SSH key
agenix -e secrets/ssh-key-github.age
```

Use in configuration:

```nix
# modules/nixos/core/secrets.nix
{
  age.secrets.ssh-key-github = {
    file = ../../../secrets/ssh-key-github.age;
    path = "/home/${config.mySystem.username}/.ssh/id_ed25519_github";
    owner = config.mySystem.username;
    mode = "600";
  };
}
```

### Option 3: Manual Key Management

For development machines, you can manually manage keys:

```bash
# Generate new SSH key
ssh-keygen -t ed25519 -C "user@example.com" -f ~/.ssh/id_ed25519

# Add to SSH agent
ssh-add ~/.ssh/id_ed25519
```

### Option 4: Hardware Security Keys

Use a YubiKey or similar hardware token:

```nix
# Enable smartcard support
services.pcscd.enable = true;
programs.gnupg.agent = {
  enable = true;
  enableSSHSupport = true;
  pinentryFlavor = "curses";
};
```

## 3. Host Keys Management

### Persistent Host Keys

Host keys are configured to persist in `/etc/ssh/` by default. For cloud instances, you might want to back them up:

```bash
# Backup host keys
sudo tar -czf host-keys-backup.tar.gz /etc/ssh/ssh_host_*

# Restore on new instance
sudo tar -xzf host-keys-backup.tar.gz -C /
```

### Known Hosts

Configure known hosts to avoid MITM attacks:

```nix
# modules/nixos/core/known-hosts.nix
{
  mySystem.ssh.knownHosts = {
    "github.com" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
    "gitlab.com" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjlhUpg51r/IHs9Vq2bXEEcmHPQCLwjJjiZI";
    };
    "bitbucket.org" = {
      publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDQeJzhupRu0u0cdegZIa8e86EG2qOCsIsD1Xw0xSeiPDlCr7kq97NLmMbpKTRTocPJwTIuNwellpKSTRLfOjv7qGZrKa0np0Ng7wt8L+zfmLGm9bR4sSbZ9xZauPKL5IqnR5";
    };
  };
}
```

## 4. SSH Agent Forwarding

For accessing git repositories through jump hosts:

```nix
# Enable agent forwarding for specific hosts
programs.ssh.matchBlocks."jump.example.com" = {
  forwardAgent = true;
};
```

## 5. Per-Machine Key Rotation

Create a script for key rotation:

```nix
# modules/nixos/services/ssh-rotation.nix
{
  systemd.services.ssh-key-rotation = {
    description = "Rotate SSH host keys";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "rotate-ssh-keys" ''
        # Backup old keys
        cp -a /etc/ssh /etc/ssh.backup-$(date +%Y%m%d)
        
        # Generate new keys
        rm -f /etc/ssh/ssh_host_*
        ssh-keygen -A
        
        # Restart SSH
        systemctl restart sshd
      '';
    };
  };
  
  systemd.timers.ssh-key-rotation = {
    description = "Rotate SSH keys monthly";
    timerConfig = {
      OnCalendar = "monthly";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };
}
```

## Best Practices

1. **Use Ed25519 keys**: More secure and faster than RSA
   ```bash
   ssh-keygen -t ed25519 -C "your-email@example.com"
   ```

2. **Separate keys for different purposes**:
   - Personal GitHub/GitLab
   - Work repositories  
   - Server access
   - Emergency access

3. **Regular key rotation**: Rotate keys every 6-12 months

4. **Use hardware tokens** for high-security environments

5. **Enable 2FA** where possible (GitHub, GitLab support TOTP)

6. **Audit key usage**: Review authorized_keys regularly

## Example: Complete Setup

```nix
# hosts/gce/default.nix
{
  imports = [
    ./ssh-keys.nix  # Authorized public keys
  ];
  
  # Known hosts for this machine
  mySystem.ssh.knownHosts = {
    "github.com" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
  };
}

# hosts/gce/ssh-keys.nix  
{
  mySystem.ssh.authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG... user@macbook"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH... user@emergency"
  ];
}
```