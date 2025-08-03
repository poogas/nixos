{ pkgs, lib, inputs, ... }:

let
  # Пакет для fabric-cli, собранный с помощью buildGoModule
  fabric-cli-pkg = pkgs.buildGoModule {
    pname = "fabric-cli-go";
    version = "git";
    src = inputs.fabric-cli;

    # === КЛЮЧЕВОЕ ИСПРАВЛЕНИЕ: Правильное имя аргумента ===
    vendorHash = "sha256-3ToIL4MmpMBbN8wTaV3UxMbOAcZY8odqJyWpQ7jkXOc=";

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
