{ pkgs, lib, inputs, ... }:

let
  # Пакет для fabric-cli, который мы УСПЕШНО собрали
  fabric-cli-pkg = pkgs.buildGoModule {
    pname = "fabric-cli-go";
    version = "git";
    src = inputs.fabric-cli;
    vendorHash = "sha256-3ToIL4MmpMBbN8wTaV3UxMbOAcZY8odqJyWpQ7jkXOc="; # Правильный хеш
    meta = with lib; {
      description = "A CLI utility for Fabric written in Go";
      homepage = "https://github.com/Fabric-Development/fabric-cli";
      license = licenses.gpl3Plus;
    };
  };

  # Наш рабочий пакет для python-gtk-env
  python-gtk-env =
    let
      python-with-all-packages = pkgs.python312.withPackages (ps: with ps; [
        python-fabric pygobject3 ijson numpy pillow psutil pywayland requests
        setproctitle toml watchdog click pycairo loguru
      ]);
    in
    pkgs.stdenv.mkDerivation {
      name = "python-gtk-environment";
      buildInputs = [ python-with-all-packages ] ++ (with pkgs; [
        gtk3 gtk-layer-shell cairo gobject-introspection libdbusmenu-gtk3
        gdk-pixbuf gnome-bluetooth cinnamon-desktop librsvg vte
      ]);
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/bin
        cat > $out/bin/python-gtk-env << EOF
        #!${pkgs.stdenv.shell}
        GI_TYPELIB_PATH="$GI_TYPELIB_PATH" \
        GDK_PIXBUF_MODULE_FILE="$GDK_PIXBUF_MODULE_FILE" \
        exec ${python-with-all-packages}/bin/python "\$@"
        EOF
        chmod +x $out/bin/python-gtk-env
      '';
    };

in
{
  # Конфигурация вашей системы
  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # ======================== ДОБАВЛЕННЫЙ БЛОК ========================
  # Шрифты лучше определять в специальной секции
  fonts.packages = with pkgs; [
    noto-fonts-emoji
  ];
  # =================================================================

  # Пакеты для установки
  environment.systemPackages = with pkgs; [
    # Ваши основные утилиты
    neovim git telegram-desktop

    # Зависимости ax-shell
    brightnessctl cava cliphist gpu-screen-recorder-gtk hypridle hyprlock
    hyprpicker hyprshot hyprsunset imagemagick libnotify nvtopPackages.nvidia
    playerctl power-profiles-daemon swappy swww tesseract tmux unzip upower
    webp-pixbuf-loader wl-clipboard

    # === ДОБАВЛЕНЫ НЕДОСТАЮЩИЕ ПАКЕТЫ ИЗ NIXPKGS ===
    matugen
    grimblast

    # Наши два кастомных пакета
    python-gtk-env
    fabric-cli-pkg
  ];
}
