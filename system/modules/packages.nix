# Важно: Добавляем `inputs` в аргументы модуля, чтобы получить доступ к fabric-cli
{ pkgs, lib, inputs, ... }:

let
  # --- НАШИ КАСТОМНЫЕ ПАКЕТЫ ---

  # 1. Рабочая обертка для Python, которую мы успешно создали.
  # Она предоставляет команду `python-gtk-env`
  python-gtk-env =
    let
      gtk-dependencies = with pkgs; [
        gtk3 gobject-introspection cairo gdk-pixbuf gtk-layer-shell
        libdbusmenu-gtk3 cinnamon-desktop gnome-bluetooth vte librsvg
      ];
      python-with-all-packages = pkgs.python312.withPackages (ps: with ps; [
        python-fabric pygobject3 ijson numpy pillow psutil pywayland requests
        setproctitle toml watchdog click pycairo loguru
      ]);
    in
    (pkgs.writeShellScriptBin "python-gtk-env" ''
      #!${pkgs.stdenv.shell}
      export GI_TYPELIB_PATH="${lib.makeSearchPath "lib/girepository-1.0" gtk-dependencies}''${GI_TYPELIB_PATH:+:}$GI_TYPELIB_PATH"
      export XDG_DATA_DIRS="${lib.makeSearchPath "share" gtk-dependencies}''${XDG_DATA_DIRS:+:}$XDG_DATA_DIRS"
      exec "${python-with-all-packages}/bin/python" "$@"
    '');

  # 2. НОВЫЙ пакет для fabric-cli, собранный из Flake input.
  # Он предоставляет команду `fabric-cli`.
  fabric-cli-pkg = pkgs.stdenv.mkDerivation {
    pname = "fabric-cli-go";
    version = "git";

    # Используем `inputs` из flake.nix, хеш не нужен
    src = inputs.fabric-cli;

    # Указываем правильные зависимости для сборки на Go
    nativeBuildInputs = with pkgs; [ go meson ninja ];

    # Указываем правильные команды сборки
    installPhase = ''
      meson setup --buildtype=release --prefix=$out build
      meson install -C build
    '';

    meta = with lib; {
      description = "A CLI utility for Fabric written in Go";
      homepage = "https://github.com/Fabric-Development/fabric-cli";
      license = licenses.gpl3Plus;
    };
  };

in
{
  # --- ОСНОВНАЯ ЧАСТЬ ВАШЕЙ КОНФИГУРАЦИИ ---

  programs.firefox.enable = true;
  programs.gpu-screen-recorder.enable = true;
  nixpkgs.config.allowUnfree = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  environment.systemPackages = with pkgs; [
    # Ваши основные утилиты
    neovim
    git
    telegram-desktop

    # Основные зависимости ax-shell
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

    # Наши два кастомных, правильно собранных пакета
    python-gtk-env
    fabric-cli-pkg
  ];
}
