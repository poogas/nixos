# /etc/nixos/home-manager/modules/hypridle.nix
{ pkgs, ... }:

{
  # Включаем и настраиваем сервис hypridle через специальный модуль Home Manager
  services.hypridle = {
    enable = true;
    # Мы используем пакет hyprlock из nixpkgs
    package = pkgs.hyprlock;
    # Настройки, которые вы нашли. Они определяют поведение при бездействии.
    settings = {
      general = {
        # === ИСПРАВЛЕНИЕ 1: Правильный путь к hyprctl ===
        lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
      };

      # Список "слушателей" бездействия
      listener = [
        {
          timeout = 180; # через 3 минуты
          on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 30"; # приглушить экран
          on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r"; # восстановить яркость
        }
        {
          timeout = 300; # через 5 минут
          on-timeout = "loginctl lock-session"; # заблокировать сессию
        }
        {
          timeout = 600; # через 10 минут
          # === ИСПРАВЛЕНИЕ 2: Правильный путь к hyprctl ===
          on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off"; # выключить экран
          on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on"; # включить экран
        }
        # {
        #   timeout = 1200; # через 20 минут
        #   on-timeout = "systemctl suspend"; # уйти в сон
        # }
      ];
    };
  };
}
