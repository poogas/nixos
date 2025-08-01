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
      
      nix-hosts = {
        "qwerty" = { 
          system = "x86_64-linux"; 
        };
      };
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs (hostname: hostConfig: 
        nixpkgs.lib.nixosSystem {
          system = hostConfig.system;
          specialArgs = { inherit inputs stateVersion hostConfig; };
          
          modules = [
            ./system/configuration.nix

            home-manager.nixosModules.home-manager
            {
	      home-manager.backupFileExtension = "hm-backup";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.qwerty =
              (import ./home-manager/home.nix) {
                inherit stateVersion;
                hyprland-pkg = inputs.hyprland.packages.${hostConfig.system}.hyprland;
              };
	    }
          ];
        }
      ) nix-hosts;
    };
}
