# /etc/nixos/home-manager/modules/hypridle.nix
{ pkgs, ... }:

{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # Теперь просто вызываем hyprlock
        lock_cmd = "${pkgs.hyprlock}/bin/hyprlock";
        before_sleep_cmd = "${pkgs.hyprlock}/bin/hyprlock";
        after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "${pkgs.hyprlock}/bin/hyprlock";
        }
        {
          timeout = 600;
          on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
          on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
