# Важно: Добавляем `inputs` в аргументы модуля, чтобы получить доступ к fabric-cli
{ pkgs, lib, inputs, ... }:

let
  # --- НАШИ КАСТОМНЫЕ ПАКЕТЫ ---

  # 1. Рабочая обертка для Python, которую мы успешно создали.
  python-gtk-env = pkgs.stdenv.mkDerivation {
    name = "python-gtk-environment";
    buildInputs = [
      (pkgs.python312.withPackages (ps: with ps; [
        python-fabric pygobject3 ijson numpy pillow psutil pywayland requests
        setproctitle toml watchdog click pycairo loguru
      ]))
    ] ++ (with pkgs; [
      gtk3 gtk-layer-shell cairo gobject-introspection libdbusmenu-gtk3
      gdk-pixbuf gnome-bluetooth cinnamon-desktop librsvg vte
    ]);
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin
      cat > $out/bin/python-gtk-env << EOF
      #!${pkgs.stdenv.shell}
      export GI_TYPELIB_PATH="$GI_TYPELIB_PATH"
      export GDK_PIXBUF_MODULE_FILE="$GDK_PIXBUF_MODULE_FILE"
      exec ${pkgs.python312.withPackages (ps: with ps; [ python-fabric ])}/bin/python "\$@"
      EOF
      chmod +x $out/bin/python-gtk-env
    '';
  };

  # 2. НОВЫЙ пакет для fabric-cli, собранный из Flake input
  fabric-cli-pkg = pkgs.stdenv.mkDerivation {
    pname = "fabric-cli-go";
    version = "git";
    src = inputs.fabric-cli; # Используем input, хеш не нужен
    nativeBuildInputs = with pkgs; [ go meson ninja ];
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
