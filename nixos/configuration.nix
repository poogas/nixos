# nixos/configuration.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./hosts.nix
    ./hyprland.nix

    inputs.hyprland.nixosModules.default
  ];

  # Убеждаемся, что кастомный модуль nvidia включен
  drivers.nvidia.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "qwerty";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Volgograd";
  i18n.defaultLocale = "en_US.UTF-8";
  # i18n.extraLocaleSettings = { ... }; # Это можно оставить

  # --- УДАЛЯЕМ СЛЕДУЮЩИЕ СТРОКИ, т.к. они переехали в hyprland.nix или больше не нужны ---
  # services.xserver.enable = true; # Hyprland сам управляет этим
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  # services.xserver.xkb = { ... }; # Настройка клавиатуры будет в Hyprland
  # services.printing.enable = true; # Можно оставить, если нужно
  # services.pulseaudio.enable = false;
  # security.rtkit.enable = true;
  # services.pipewire = { ... };
  # --------------------------------------------------------------------------------------

  users.users.qwerty = {
    isNormalUser = true;
    description = "qwerty";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    shell = pkgs.bash;
    # createHome, home, group - можно убрать, NixOS сделает это по умолчанию с isNormalUser
  };

  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  # Системные пакеты теперь лучше определять в hyprland.nix
  # или оставить здесь только то, что не относится к GUI
  environment.systemPackages = with pkgs; [
    neovim
    git
    telegram-desktop # Он останется, но может потребоваться настройка для Wayland
  ];

  system.stateVersion = "25.05";
}
