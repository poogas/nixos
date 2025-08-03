{ pkgs, ... }:

let
  # Шаг 1: Определяем все системные C-библиотеки, которые нам нужны.
  # Этот список мы взяли из default.nix самого Fabric, чтобы обеспечить совместимость.
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

    # Системные утилиты, необходимые для ax-shell
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

    # ======================== ФИНАЛЬНОЕ РЕШЕНИЕ ========================
    # Шаг 3: Создаем скрипт-обертку.
    # Мы используем `writeShellScriptBin` и двойные кавычки ("...") для правильной
    # подстановки Nix-переменных в итоговый shell-скрипт.
    (pkgs.writeShellScriptBin "python-with-ax-shell-env" ''
      #!${pkgs.stdenv.shell}

      # Устанавливаем переменную для поиска .typelib файлов (карты C-библиотек).
      # Мы добавляем пути к существующей переменной, если она уже задана.
      export GI_TYPELIB_PATH="${pkgs.lib.makeSearchPathOutput "lib/girepository-1.0" gtk-dependencies}''${GI_TYPELIB_PATH:+:}$GI_TYPELIB_PATH"

      # Устанавливаем переменную для поиска данных (иконки, схемы и т.д.)
      export XDG_DATA_DIRS="${pkgs.lib.makeSearchPath "share" gtk-dependencies}''${XDG_DATA_DIRS:+:}$XDG_DATA_DIRS"

      # Запускаем наш специально собранный Python, передавая ему все аргументы.
      # `exec` заменяет процесс оболочки процессом Python для эффективности.
      exec "${python-with-fabric}/bin/python" "$@"
    '')
    # =======================================================================
  ];
}
