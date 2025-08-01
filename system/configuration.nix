{ config, pkgs, inputs, hostname, username, stateVersion, ... }:

{
  imports = [
    ./modules/hardware-configuration.nix
    ./modules/nvidia.nix
    ./modules/hosts.nix
    ./modules/hyprland.nix

    inputs.hyprland.nixosModules.default
  ];

  drivers.nvidia.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.trusted-users = [ "root" username ];

  nix = {
    settings.auto-optimise-store = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Volgograd";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users."${username}" = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    shell = pkgs.bash;
  };

  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neovim
    git
    telegram-desktop 
  ];

  system.stateVersion = stateVersion;
}
