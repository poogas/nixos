{ config, pkgs, inputs, hostname, username, stateVersion, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./hosts.nix
    ./hyprland.nix

    # inputs.hyprland.nixosModules.default

    ./modules
  ];

  drivers.nvidia.enable = true;

  system.stateVersion = stateVersion;
}
