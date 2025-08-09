# /etc/nixos/system/modules/packages.nix

{ pkgs, lib, inputs, ... }:

let
  # === ШАГ 1: Создаем окружение с помощью `withPackages` ===
  # Теперь, когда `python-fabric` правильно добавлен через оверлей,
  # этот метод будет работать идеально.
  pythonEnv = (pkgs.python311.withPackages (ps: with ps; [
    python-fabric # <--- Наш новый, правильно собранный пакет
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
    click
    pycairo
    loguru
  ]));

  # === ШАГ 2: Создаем лаунчер ===
  ax-shell-launcher = pkgs.stdenv.mkDerivation {
    name = "ax-shell-launcher-from-working-example";

    nativeBuildInputs = [ pkgs.wrapGAppsHook3 ];

    buildInputs = [ pythonEnv ] ++ (with pkgs; [
      glib
      gtk3 gtk-layer-shell cairo gobject-introspection libdbusmenu-gtk3
      gdk-pixbuf gnome-bluetooth cinnamon-desktop librsvg vte
    ]);

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      cat > $out/bin/ax-shell-launcher << EOF
      #!${pkgs.stdenv.shell}
      exec ${pythonEnv}/bin/python ${inputs.ax-shell-src}/main.py
      EOF
      chmod +x $out/bin/ax-shell-launcher
    '';
  };

  # Остальные ваши пакеты (не относящиеся к fabric).
  fabric-cli-pkg = pkgs.buildGoModule {
    pname = "fabric-cli-go";
    version = "git";
    src = inputs.fabric-cli;
    vendorHash = "sha256-3ToIL4MmpMBbN8wTaV3UxMbOAcZY8odqJyWpQ7jkXOc=";
  };
  zed-sans-font = pkgs.stdenv.mkDerivation rec {
    pname = "zed-sans";
    version = "1.2.0";
    src = pkgs.fetchurl {
      url = "https://github.com/zed-industries/zed-fonts/releases/download/${version}/zed-sans-${version}.zip";
      sha256 = "sha256-64YcNcbxY5pnR5P3ETWxNw/+/JvW5ppf9f/6JlnxUME=";
    };
    dontUnpack = true;
    nativeBuildInputs = [ pkgs.unzip ];
    installPhase = ''
      mkdir -p $out/share/fonts/opentype
      unzip -j $src -d $out/share/fonts/opentype
    '';
  };

in
{
  # --- ОСНОВНАЯ ЧАСТЬ ВАШЕЙ КОНФИГУРАЦИИ ---
  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts-emoji
    zed-sans-font
  ];

  environment.systemPackages = with pkgs; [
    # Зависимости
    brightnessctl cava cliphist gpu-screen-recorder-gtk hypridle hyprlock
    hyprpicker hyprshot hyprsunset imagemagick libnotify nvtopPackages.nvidia
    playerctl power-profiles-daemon swappy swww tesseract tmux unzip upower
    webp-pixbuf-loader wl-clipboard matugen grimblast

    # Наш финальный собранный пакет
    ax-shell-launcher

    # Прочие
    fabric-cli-pkg
    inputs.gray.packages."x86_64-linux".default
    wlinhibit
    uwsm
  ];
}
