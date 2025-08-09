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

    # ======================== ИСПРАВЛЕННЫЙ БЛОК ========================
    # Добавляем fabric-cli как "вход", но явно указываем, что это НЕ Flake.
    fabric-cli = {
      url = "github:Fabric-Development/fabric-cli";
      flake = false; # <--- КЛЮЧЕВОЕ ИСПРАВЛЕНИЕ
    };
    # =================================================================
    gray = {
      url = "github:Fabric-Development/gray";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Добавляем исходники Ax-Shell как input, который не является Flake
    ax-shell-src = {
      url = "github:Axenide/Ax-Shell";
      flake = false;
    };
  };

  # Мы добавляем `fabric-cli` в аргументы функции, чтобы иметь к нему доступ.
  outputs = { self, nixpkgs, home-manager, hyprland, fabric, fabric-cli, gray, ax-shell-src, ... }@inputs:
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
		(import ./system/overlay.nix)
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
