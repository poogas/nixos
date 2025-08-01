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
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }@inputs:
    let
      stateVersion = "25.05";
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      
      nix-hosts = {
        "qwerty" = { 
          system = "x86_64-linux"; 
        };
      };
    in
    {
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt
      );

      nixosConfigurations = nixpkgs.lib.mapAttrs (hostname: hostConfig: 
        nixpkgs.lib.nixosSystem {
          system = hostConfig.system;
          specialArgs = { inherit inputs stateVersion hostConfig; };
          
          modules = [
            ./nixos/configuration.nix

            home-manager.nixosModules.home-manager
            {
	      home-manager.backupFileExtension = "hm-backup";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.qwerty =
              (import ./home-manager/home.nix) {
                inherit stateVersion;
                hyprland-pkg = inputs.hyprland.packages.${"x86_64-linux"}.hyprland;
              };
	    }
          ];
        }
      ) nix-hosts;
    };
}
