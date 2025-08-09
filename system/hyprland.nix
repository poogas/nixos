# nixos/hyprland.nix
{ config, pkgs, inputs, ... }:

{
  # 1. Включаем Hyprland и основные программы
  programs.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    package = pkgs.hyprland;
    xwayland.enable = true;
    withUWSM = true;
  };

  # 2. Настраиваем графический вход через SDDM
  services.displayManager = {
    # Отключаем GDM от GNOME
    # gdm.enable = false;
    # Включаем SDDM
    sddm = {
      enable = true;
      # Запускаем сам SDDM под Wayland для лучшей совместимости
      wayland.enable = true;
    };
  };

  # 4. Настройка звуковой подсистемы
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


  # 5. Переменные окружения для Wayland и NVIDIA
  environment.sessionVariables = {
    # Стандартные переменные Wayland
    MOZ_ENABLE_WAYLAND = "1";

    # Переменные, критически важные для NVIDIA
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
  };


  # 6. Системные пакеты для окружения Hyprland
  environment.systemPackages = with pkgs; [
    # Утилиты для Wayland
    wofi         # Лаунчер приложений
    mako         # Демон уведомлений
    grim         # Создание скриншотов
    slurp        # Выделение области экрана (для grim)
    wl-clipboard # Утилита для буфера обмена в Wayland

    # Шрифты и иконки
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome # Для иконок в waybar
  ];


  # 7. Параметры ядра для NVIDIA и сети
  # boot.kernelParams = [ "ipv6.disable=1" "nvidia-drm.modeset=1" "net.ipv4.tcp_window_scaling=0" "net.ipv4.ip_no_pmtu_disc=1" ];


  # 8. Отключаем текстовые терминалы на главном экране
  # Теперь их место займет SDDM
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}
