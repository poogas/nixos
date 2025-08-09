# /etc/nixos/system/modules/packages.nix

{ pkgs, lib, inputs, ... }:

let
  # === ШАГ 1: Локально собираем python-fabric ===
  python-fabric = pkgs.python311Packages.buildPythonPackage {
    pname = "python-fabric";
    version = "unstable";
    pyproject = true;
    src = inputs.fabric;

    nativeBuildInputs = with pkgs; [
      pkg-config
      wrapGAppsHook3
      gobject-introspection
      cairo
    ];

    propagatedBuildInputs = with pkgs; [
      gtk3
      gtk-layer-shell
      libdbusmenu-gtk3
      # === ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ: Убираем устаревшие "scope" ===
      # Пакеты cinnamon-desktop и gnome-bluetooth теперь находятся
      # на верхнем уровне в `pkgs`, а не внутри `pkgs.cinnamon` или `pkgs.gnome`.
      cinnamon-desktop
      gnome-bluetooth
    ] ++ (with pkgs.python311Packages; [
      setuptools
      click
      pycairo
      pygobject3
      loguru
      psutil
    ]);

    doCheck = false;
  };

  # === ШАГ 2: Создаем окружение Python с помощью `withPackages` ===
  pythonEnv = pkgs.python311.withPackages (ps: [
    python-fabric  # <--- Наша локальная переменная
  ] ++ (with ps; [
    pygobject3
    ijson
    numpy
    pillow
    pywayland
    requests
    setproctitle
    toml
    watchdog
  ]));

  # === ШАГ 3: Создаем лаунчер ===
  ax-shell-launcher = pkgs.stdenv.mkDerivation {
    name = "ax-shell-launcher-finally-working";
    nativeBuildInputs = [ pkgs.wrapGAppsHook3 ];
    buildInputs = [ pythonEnv ] ++ (with pkgs; [
      glib gtk3 gtk-layer-shell cairo gobject-introspection libdbusmenu-gtk3
      gdk-pixbuf
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

  # Остальные ваши пакеты.
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
  fonts.packages = with pkgs; [ noto-fonts-emoji zed-sans-font ];
  environment.systemPackages = with pkgs; [
    brightnessctl cava cliphist gpu-screen-recorder-gtk hypridle hyprlock
    hyprpicker hyprshot hyprsunset imagemagick libnotify nvtopPackages.nvidia
    playerctl power-profiles-daemon swappy swww tesseract tmux unzip upower
    webp-pixbuf-loader wl-clipboard matugen grimblast
    ax-shell-launcher
    fabric-cli-pkg
    inputs.gray.packages."x86_64-linux".default
    wlinhibit
    uwsm
  ];
}
