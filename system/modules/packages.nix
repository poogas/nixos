{ pkgs, ... }:

{
  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neovim
    git
    telegram-desktop
  ];
}
