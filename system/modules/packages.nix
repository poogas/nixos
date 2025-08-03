{ pkgs, lib, inputs, ... }:

let
  # ... (определения fabric-cli-pkg и python-gtk-env остаются без изменений)
  fabric-cli-pkg = pkgs.buildGoModule {
    pname = "fabric-cli-go";
    version = "git";
    src = inputs.fabric-cli;
    vendorHash = "sha256-3ToIL4MmpMBbN8wTaV3UxMbOAcZY8odqJyWpQ7jkXOc=";
    meta = with lib; { /* ... */ };
  };
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

  # Упаковываем шрифт Zed Sans
  zed-sans-font = pkgs.stdenv.mkDerivation rec {
    pname = "zed-sans";
    version = "1.2.0";

    src = pkgs.fetchurl {
      url = "https://github.com/zed-industries/zed-fonts/releases/download/${version}/zed-sans-${version}.zip";
      # У вас здесь должен быть ваш правильный хеш
      sha256 = "sha256-64YcNcbxY5pnR5P3ETWxNw/+/JvW5ppf9f/6JlnxUME="; # Пример! Вставьте свой.
    };
    
    dontUnpack = true;

    nativeBuildInputs = [ pkgs.unzip ];

    # === ИСПРАВЛЕНИЕ ЗДЕСЬ ===
    # Мы убираем маску "*.otf" и просто распаковываем все
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
    # Ваши основные утилиты
    neovim git telegram-desktop

    # Зависимости ax-shell
    brightnessctl cava cliphist gpu-screen-recorder-gtk hypridle hyprlock
    hyprpicker hyprshot hyprsunset imagemagick libnotify nvtopPackages.nvidia
    playerctl power-profiles-daemon swappy swww tesseract tmux unzip upower
    webp-pixbuf-loader wl-clipboard matugen grimblast

    # Наши кастомные пакеты
    python-gtk-env
    fabric-cli-pkg

    inputs.gray.packages."x86_64-linux".default
    wlinhibit
    uwsm
  ];
}
