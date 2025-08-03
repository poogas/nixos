{ pkgs, lib, ... }:

let
  # Шаг 1: Определяем все системные C-библиотеки, которые нам нужны.
  gtk-dependencies = with pkgs; [
    gtk3
    gobject-introspection # Пакет, чей setup hook нам нужен
    cairo
    gdk-pixbuf
    gtk-layer-shell
    libdbusmenu-gtk3
    cinnamon-desktop
    gnome-bluetooth
    vte
    librsvg # Добавлено из run-widget.nix для полноты
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

    # ======================== ФИНАЛЬНОЕ РЕШЕНИЕ (mkDerivation done right) =======================
    # Шаг 3: Создаем derivation, который позволяет автоматическим хукам NixOS сделать свою работу.
    (stdenv.mkDerivation {
      name = "python-with-ax-shell-env";
      
      # Передаем GTK-зависимости в buildInputs. Это позволяет их setup-hook'ам
      # автоматически обернуть все, что мы создаем в installPhase.
      nativeBuildInputs = [ makeWrapper ] ++ gtk-dependencies;
      
      dontUnpack = true;

      # В installPhase мы просто создаем скрипт-обертку.
      # Автоматические хуки сами добавят нужные export'ы переменных окружения.
      installPhase = ''
        mkdir -p $out/bin
        makeWrapper ${python-with-fabric}/bin/python $out/bin/python-with-ax-shell-env
      '';
    })
    # =========================================================================================
  ];
}
