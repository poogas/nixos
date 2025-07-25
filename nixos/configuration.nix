{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./hosts.nix
  ];

  drivers.nvidia.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "qwerty";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Volgograd";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # users.users.qwerty = {
  #   isNormalUser = true;
  #   description = "qwerty";
  #   extraGroups = [ "networkmanager" "wheel" ];
  #   packages = with pkgs; [ ];
  # };

  users.users.qwerty = {
    isNormalUser = true;
    description = "qwerty";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    home = "/home/qwerty";
    createHome = true;
    group = "qwerty";
    shell = pkgs.bash;
  };

  users.groups.qwerty = {};

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "qwerty";

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  programs.firefox.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neovim
    git
    telegram-desktop
  ];

  system.stateVersion = "25.05";
}
