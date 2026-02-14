{
  description = "Modular NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
  let
    # Home-manager configuration that uses the system's username
    homeManagerConfig = { config, ... }: {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${config.mySystem.username} = {
          home.stateVersion = "25.05";
          imports = [ ./modules/home/default.nix ];
        };
      };
    };
  in
  {
    nixosConfigurations = {

      # Vmware VM (Apple Silicon M4)
      vmware = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/vmware/default.nix
          home-manager.nixosModules.home-manager
          homeManagerConfig
        ];
      };

      # Parallels VM (Apple Silicon M4)
      parallels = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/parallels/default.nix
          home-manager.nixosModules.home-manager
          homeManagerConfig
        ];
      };

      # AWS EC2
      aws-ec2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/aws-ec2/default.nix
          home-manager.nixosModules.home-manager
          homeManagerConfig
        ];
      };

      # Google Compute Engine
      gce = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/gce/default.nix
          home-manager.nixosModules.home-manager
          homeManagerConfig
        ];
      };

      # Legacy name for current GCE instance
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/gce/default.nix
          home-manager.nixosModules.home-manager
          homeManagerConfig
        ];
      };
    };
    
    # Formatter for nix files
    formatter = {
      x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-classic;
      aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt-classic;
    };
  };
}
