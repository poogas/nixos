{ pkgs, lib, inputs, ... }:

let
  # Пакет для fabric-cli, собранный из Flake input
  fabric-cli-pkg = pkgs.stdenv.mkDerivation {
    pname = "fabric-cli-go";
    version = "git";
    src = inputs.fabric-cli;

    nativeBuildInputs = with pkgs; [ go meson ninja ];

    # === ИСПРАВЛЕНИЕ ЗДЕСЬ ===
    installPhase = ''
      # Устанавливаем переменные окружения, чтобы Go не пытался писать в /homeless-shelter
      export HOME=$(mktemp -d)
      export GOCACHE=$HOME/go-cache

      # Теперь запускаем команды сборки, которые раньше падали
      meson setup --buildtype=release --prefix=$out build
      meson install -C build
    '';

    meta = with lib; {
      description = "A CLI utility for Fabric written in Go";
      homepage = "https://github.com/Fabric-Development/fabric-cli";
      license = licenses.gpl3Plus;
    };
  };

  # Ваша рабочая обертка для Python
  python-gtk-env = (pkgs.writeShellScriptBin "python-gtk-env" ''
    #!${pkgs.stdenv.shell}
    export GI_TYPELIB_PATH="${lib.makeSearchPath "lib/girepository-1.0" (with pkgs; [gtk3 gobject-introspection cairo gdk-pixbuf gtk-layer-shell libdbusmenu-gtk3 cinnamon-desktop gnome-bluetooth vte librsvg])}''${GI_TYPELIB_PATH:+:}$GI_TYPELIB_PATH"
    export XDG_DATA_DIRS="${lib.makeSearchPath "share" (with pkgs; [gtk3 gobject-introspection cairo gdk-pixbuf gtk-layer-shell libdbusmenu-gtk3 cinnamon-desktop gnome-bluetooth vte librsvg])}''${XDG_DATA_DIRS:+:}$XDG_DATA_DIRS"
    exec "${pkgs.python312.withPackages (ps: with ps; [python-fabric pygobject3 ijson numpy pillow psutil pywayland requests setproctitle toml watchdog click pycairo loguru])}/bin/python" "$@"
  '');

in
{
  # Конфигурация вашей системы...
  programs.firefox.enable = true;
  gpu-screen-recorder.enable = true;
  nixpkgs.config.allowUnfree = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # Пакеты для установки
  environment.systemPackages = with pkgs; [
    neovim git telegram-desktop
    brightnessctl cava cliphist gpu-screen-recorder-gtk hypridle hyprlock hyprpicker hyprshot hyprsunset imagemagick libnotify nvtopPackages.nvidia playerctl power-profiles-daemon swappy swww tesseract tmux unzip upower webp-pixbuf-loader wl-clipboard
    python-gtk-env
    fabric-cli-pkg
  ];
}
