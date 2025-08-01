# nixos/hyprland.nix
{ config, pkgs, inputs, ... }: # Обратите внимание на 'inputs', он пришел из specialArgs

{
  # Включаем Hyprland
  programs.hyprland = {
    enable = true;
    # Используем пакет из flake input для самой свежей версии
    package = inputs.hyprland.packages.${pkgs.system}.hyprland; 
    # Отключаем xwayland, если вы уверены, что не будете запускать X11 приложения.
    # Для начала лучше оставить включенным.
    xwayland.enable = true;
  };

  # Отключаем GNOME и GDM
  services.xserver.desktopManager.gnome.enable = false;
  services.xserver.displayManager.gdm.enable = false;
  
  # Включаем Pipewire для аудио
  # У вас это уже было, но важно убедиться, что оно есть
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Настройка окружения для Wayland
  environment.sessionVariables = {
    # Подсказка для Firefox, чтобы он использовал Wayland
    MOZ_ENABLE_WAYLAND = "1";
    # Если вы столкнетесь с проблемами рендеринга в Electron-приложениях
    # NIXOS_OZONE_WL = "1"; 
  };
  
  # Установка необходимых пакетов для полноценного окружения
  environment.systemPackages = with pkgs; [
    # Утилиты для Wayland
    waybar       # Статус-бар
    wofi         # Лаунчер приложений
    mako         # Демон уведомлений
    swaylock     # Блокировщик экрана
    swayidle     # Управление бездействием (для блокировки)
    grim         # Создание скриншотов
    slurp        # Выделение области экрана (для grim)
    wl-clipboard # Утилита для буфера обмена в Wayland
    
    # Терминал (у вас уже есть alacritty в home-manager, что хорошо)
    alacritty
    
    # Шрифты, иконки
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    font-awesome # Для иконок в waybar
  ];
  
  # ВАЖНО: Настройка для NVIDIA
  # Hyprland требует, чтобы DRM modesetting был включен
  # Ваш модуль nvidia.nix уже делает это с `hardware.nvidia.modesetting.enable = true;`, что отлично!
  # Но нам также нужно добавить параметр ядра.
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  # Убираем консольный автологин, если он был настроен для tty
  systemd.services."getty@tty1".enable = true;
  systemd.services."autovt@tty1".enable = true;
  services.displayManager.autoLogin.enable = false; # Отключаем автологин GDM
}
