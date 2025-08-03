{ pkgs, lib, ... }:

let
  # Шаг 1: Создаем наш специальный Python-интерпретатор со всеми нужными ему пакетами.
  # Это будет одним из "кирпичиков" для финального пакета.
  python-with-all-packages = pkgs.python312.withPackages (ps: with ps; [
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
    # Дополнительные пакеты, которые мы видим в devShell файла fabric/flake.nix
    click
    pycairo
    loguru
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

    # ======================== ФИНАЛЬНОЕ РЕШЕНИЕ (по образу run-widget.nix) =======================
    # Создаем наш финальный пакет-обертку.
    (pkgs.stdenv.mkDerivation {
      name = "python-gtk-environment";
      
      # В buildInputs мы кладем ВСЕ: и Python, и все GTK-библиотеки.
      # Это позволяет setup-hook'ам из gobject-introspection и других пакетов
      # правильно подготовить среду сборки.
      buildInputs = [ python-with-all-packages ] ++ (with pkgs; [
        gtk3
        gtk-layer-shell
        cairo
        gobject-introspection
        libdbusmenu-gtk3
        gdk-pixbuf
        gnome-bluetooth
        cinnamon-desktop
        librsvg
        vte
      ]);
      
      # Нам не нужны исходники, мы только пишем скрипт
      dontUnpack = true;

      # Фаза установки, которая в точности повторяет логику run-widget.nix
      installPhase = ''
        mkdir -p $out/bin
        # Создаем наш исполняемый файл
        cat > $out/bin/python-gtk-env << EOF
        #!${pkgs.stdenv.shell}
        # Захватываем переменные, подготовленные setup-hook'ами в среде сборки
        export GI_TYPELIB_PATH="$GI_TYPELIB_PATH"
        export GDK_PIXBUF_MODULE_FILE="$GDK_PIXBUF_MODULE_FILE"
        # Запускаем Python из нашего специального окружения
        exec ${python-with-all-packages}/bin/python "\$@"
        EOF
        # Делаем его исполняемым
        chmod +x $out/bin/python-gtk-env
      '';
    })
    # =========================================================================================
  ];
}
