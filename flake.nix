# --- Файл: flake.nix ---
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
      # Определяем наши хосты и их параметры в одном месте.
      # Вы можете добавить сюда больше хостов в будущем.
      nix-hosts = {
        "qwerty" = {
          system = "x86_64-linux";
          # Версия для system.stateVersion
          systemStateVersion = "25.05";
          # Версия для home.stateVersion
          homeStateVersion = "25.05";
        };
      };

      # Вспомогательная функция для создания конфигурации системы
      makeSystem = { hostname, hostConfig }:
        nixpkgs.lib.nixosSystem {
          system = hostConfig.system;

          # Здесь мы передаем переменные во все модули
          specialArgs = {
            inherit inputs;
            # Передаем конкретные версии для этого хоста
            stateVersion = hostConfig.systemStateVersion;
            homeStateVersion = hostConfig.homeStateVersion;
            # Также передаем пакет hyprland, чтобы он был доступен в home.nix
            hyprland-pkg = inputs.hyprland.packages.${hostConfig.system}.hyprland;
          };

          modules = [
            # 1. Системный модуль, который получит доступ к stateVersion
            ./system/configuration.nix

            # 2. Модуль Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-backup";
              home-manager.users.qwerty = {
                # 3. Домашний модуль, который получит доступ к homeStateVersion
                imports = [ ./home-manager/home.nix ];
              };
            }
          ];
        };
    in
    {
      # Создаем конфигурации для каждого хоста из списка nix-hosts
      nixosConfigurations = nixpkgs.lib.mapAttrs (hostname: hostConfig:
        makeSystem { inherit hostname hostConfig; }
      ) nix-hosts;
    };
}
