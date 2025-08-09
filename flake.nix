# /etc/nixos/flake.nix

{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fabric.url = "github:Fabric-Development/fabric";
    fabric-cli = {
      url = "github:Fabric-Development/fabric-cli";
      flake = false;
    };
    gray = {
      url = "github:Fabric-Development/gray";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ax-shell-src = {
      url = "github:Axenide/Ax-Shell";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      nix-hosts = {
        "qwerty" = {
          username = "qwerty";
          system = "x86_64-linux";
          systemStateVersion = "25.05";
          homeStateVersion = "25.05";
        };
      };

      makeSystem = { hostname, hostConfig }:
        nixpkgs.lib.nixosSystem {
          system = hostConfig.system;

          # specialArgs больше не нужны, NixOS передаст все сама.
          specialArgs = {
            inherit inputs;
            hostname = hostname;
            username = hostConfig.username;
            stateVersion = hostConfig.systemStateVersion;
          };

          modules = [
            ./system/configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-backup";

              # Мы убираем отсюда сложную передачу hyprland-pkg
              home-manager.extraSpecialArgs = {
                inherit inputs;
                username = hostConfig.username;
                homeStateVersion = hostConfig.homeStateVersion;
                ax-shell-src = inputs.ax-shell-src;
              };

              home-manager.users."${hostConfig.username}" = {
                imports = [ ./home-manager/home.nix ];
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs (hostname: hostConfig:
        makeSystem { inherit hostname hostConfig; }
      ) nix-hosts;
    };
}
