{ pkgs, lib, inputs, ... }:

let
  # === ШАГ 1: Локально собираем libcvc (Cinnamon Volume Control) ===
  libcvc = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "libcvc-gir";
    version = "unstable-from-cinnamon";

    src = pkgs.fetchgit {
      url = "https://github.com/linuxmint/cinnamon-desktop";
      rev = "6.2.0";
      hash = "sha256-9uewZh0GHQAenTcZpLchgFXSt3vOhxLbaepsJIkjTdI=";
    };

    postPatch = ''
      sed -i "s/subdir('install-scripts')/# subdir('install-scripts')/" meson.build
      sed -i "s/subdir('po')/# subdir('po')/" meson.build
      sed -i "s/subdir('libcinnamon-desktop')/# subdir('libcinnamon-desktop')/" meson.build
      sed -i "s/subdir('schemas')/# subdir('schemas')/" meson.build
    '';

    nativeBuildInputs = with pkgs; [ meson ninja pkg-config gobject-introspection ];
    buildInputs = with pkgs; [
      gdk-pixbuf gtk3 libpulseaudio systemd xkeyboard_config xorg.libxkbfile
    ];

    doCheck = false;
  });

  # === ШАГ 2: Локально собираем python-fabric с зафиксированной версией ===
  python-fabric = pkgs.python312Packages.buildPythonPackage {
    pname = "python-fabric";
    version = "unstable-pinned";
    pyproject = true;
    
    src = pkgs.fetchFromGitHub {
      owner = "Fabric-Development";
      repo = "fabric";
      rev = "02be1e1ea7e99e3cd0d70bed510ceb95813d4a67";
      sha256 = "sha256-7cFgHMZeurf9HcjVdZflvhOuVkGGALUqzLlEDsC2g0c=";
    };

    nativeBuildInputs = with pkgs; [
      pkg-config wrapGAppsHook3 gobject-introspection cairo
    ];
    propagatedBuildInputs = with pkgs; [
      gtk3 gtk-layer-shell libdbusmenu-gtk3 cinnamon-desktop gnome-bluetooth
      libcvc
    ] ++ (with pkgs.python312Packages; [
      setuptools click pycairo pygobject3 loguru psutil
    ]);
    doCheck = false;
  };

  # === ШАГ 3: Создаем окружение Python 3.12 ===
  pythonEnv = pkgs.python312.withPackages (ps: [
    python-fabric
  ] ++ (with ps; [
    pygobject3 ijson numpy pillow pywayland requests setproctitle toml watchdog
  ]));

  # === ШАГ 4: Создаем финальный лаунчер ===
  ax-shell-launcher = pkgs.stdenv.mkDerivation {
    name = "ax-shell-launcher-with-cvc";
    nativeBuildInputs = [ pkgs.wrapGAppsHook3 ];
    buildInputs = [ pythonEnv ] ++ (with pkgs; [
      glib gtk3 gtk-layer-shell cairo gobject-introspection libdbusmenu-gtk3
      gdk-pixbuf libcvc
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
    # === ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ: Правильное имя архитектуры ===
    inputs.gray.packages."x86_64-linux".default
    wlinhibit
    uwsm
  ];
}
