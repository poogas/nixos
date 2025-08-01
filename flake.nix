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

  # <<< ИЗМЕНЕНИЕ ЗДЕСЬ >>>
  # Мы добавляем home-manager и hyprland в список переменных,
  # которые извлекаются из inputs.
  outputs = { self, nixpkgs, home-manager, hyprland, ... }@inputs:
    let
      stateVersion = "25.05";
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt
      );

      nixosConfigurations = {
        qwerty = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          # Мы по-прежнему передаем ВЕСЬ набор inputs в модули, это правильно.
          specialArgs = { inherit inputs stateVersion; };
          modules = [
            ./nixos/configuration.nix

            # Теперь эта строка будет работать, т.к. home-manager в области видимости.
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.qwerty = import ./home-manager/home.nix;
            }
          ];
        };
      };
    };
}
