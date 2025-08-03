{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fabric.url = "github:Fabric-Development/fabric";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }@inputs:
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

          specialArgs = {
            inherit inputs;
	    hostname = hostname;
	    username = hostConfig.username;
            stateVersion = hostConfig.systemStateVersion;
          };

          modules = [
            ./system/configuration.nix

            ({ config, pkgs, ... }: {
              nixpkgs.overlays = [
                inputs.fabric.overlays.${hostConfig.system}.default
              ];
            })

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-backup";

              home-manager.extraSpecialArgs = {
                inherit inputs;
		username = hostConfig.username;
                homeStateVersion = hostConfig.homeStateVersion;
                hyprland-pkg = inputs.hyprland.packages.${hostConfig.system}.hyprland;
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
