{ pkgs, lib, ... }:

let
  # Шаг 1: Определяем все системные C-библиотеки, которые нам нужны.
  gtk-dependencies = with pkgs; [
    gtk3
    gobject-introspection
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

    # ======================== ФИНАЛЬНОЕ РЕШЕНИЕ (Исправленный синтаксис shell) =======================
    # Шаг 3: Создаем скрипт-обертку с синтаксически верным экспортом переменных.
    (pkgs.writeShellScriptBin "python-with-ax-shell-env" ''
      #!${pkgs.stdenv.shell}
      
      # Сначала определяем префиксы с путями из Nix
      GI_TYPELIB_PATH_PREFIX="${lib.makeSearchPath "lib/girepository-1.0" gtk-dependencies}"
      XDG_DATA_DIRS_PREFIX="${lib.makeSearchPath "share" gtk-dependencies}"

      # Теперь правильно конструируем итоговую переменную, помещая все в кавычки.
      export GI_TYPELIB_PATH="$GI_TYPELIB_PATH_PREFIX''${GI_TYPELIB_PATH:+:}$GI_TYPELIB_PATH"
      export XDG_DATA_DIRS="$XDG_DATA_DIRS_PREFIX''${XDG_DATA_DIRS:+:}$XDG_DATA_DIRS"

      # Запускаем наш специально собранный Python, передавая ему все аргументы.
      exec "${python-with-fabric}/bin/python" "$@"
    '')
    # =================================================================================================
  ];
}
