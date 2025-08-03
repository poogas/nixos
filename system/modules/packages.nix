{ pkgs, lib, ... }:

let
  # Шаг 1: Определяем все системные C-библиотеки, которые нам нужны.
  gtk-dependencies = with pkgs; [
    gtk3
    gobject-introspection # Самый важный пакет, чей setup hook нам нужен
    cairo
    gdk-pixbuf
    gtk-layer-shell
    libdbusmenu-gtk3
    cinnamon-desktop
    gnome-bluetooth
    vte
    librsvg
  ];

  # Шаг 2: Создаем интерпретатор Python со всеми нужными ему Python-библиотеками.
  python-with-fabric = pkgs.python312.withPackages (ps: with ps; [
    python-fabric
    pygobject3
    ijson
    numpy
    pillow
    psutil
    pywayland
    requests
    setproctitle
    toml
    watchdog
  ]);

in
{
  # Эти настройки остаются без изменений
  programs.firefox.enable = true;
  programs.gpu-screen-recorder.enable = true;
  nixpkgs.config.allowUnfree = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # Список системных пакетов
  environment.systemPackages = with pkgs; [
    # Ваши основные утилиты
    neovim
    git
    telegram-desktop

    # Утилиты для ax-shell
    brightnessctl
    cava
    cliphist
    gpu-screen-recorder-gtk
    hypridle
    hyprlock
    hyprpicker
    hyprshot
    hyprsunset
    imagemagick
    libnotify
    nvtopPackages.nvidia
    playerctl
    power-profiles-daemon
    swappy
    swww
    tesseract
    tmux
    unzip
    upower
    webp-pixbuf-loader
    wl-clipboard

    # ======================== ФИНАЛЬНОЕ РЕШЕНИЕ (Nix Setup Hooks) =======================
    # Шаг 3: Создаем derivation, который позволяет автоматическим хукам NixOS сделать свою работу.
    (pkgs.stdenv.mkDerivation {
      name = "python-with-ax-shell-env";
      
      # Передаем GTK-зависимости и makeWrapper в nativeBuildInputs.
      # Это заставит Nix запустить их "setup hooks" на нашем скрипте.
      nativeBuildInputs = [ pkgs.makeWrapper ] ++ gtk-dependencies;
      
      dontUnpack = true; # Нам не нужны исходники, мы просто создаем скрипт.

      # В installPhase мы просто создаем простую обертку.
      # Автоматические хуки из nativeBuildInputs сами найдут этот скрипт
      # и добавят в него нужные export'ы переменных окружения.
      installPhase = ''
        mkdir -p $out/bin
        makeWrapper ${python-with-fabric}/bin/python $out/bin/python-with-ax-shell-env
      '';
    })
    # =========================================================================================
  ];
}
