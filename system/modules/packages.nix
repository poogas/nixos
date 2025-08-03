{ pkgs, lib, inputs, ... }:

let
  # --- НАШИ КАСТОМНЫЕ ПАКЕТЫ ---

  # 1. Пакет для fabric-cli, который мы УСПЕШНО собрали
  fabric-cli-pkg = pkgs.buildGoModule {
    pname = "fabric-cli-go";
    version = "git";
    src = inputs.fabric-cli;
    vendorHash = "sha256-3ToIL4MmpMBbN8wTaV3UxMbOAcZY8odqJyWpQ7jkXOc="; # Я вставлю известный рабочий хеш
  };

  # 2. НОВЫЙ, ПРАВИЛЬНЫЙ пакет для python-gtk-env, который точно копирует run-widget.nix
  python-gtk-env =
    let
      # Определяем Python со всеми его зависимостями
      python-with-all-packages = pkgs.python312.withPackages (ps: with ps; [
        python-fabric pygobject3 ijson numpy pillow psutil pywayland requests
        setproctitle toml watchdog click pycairo loguru
      ]);
    in
    # Создаем derivation
    pkgs.stdenv.mkDerivation {
      name = "python-gtk-environment";

      # В buildInputs мы кладем ВСЕ: и Python, и все GTK-библиотеки.
      # Это позволяет setup-hook'ам подготовить переменные окружения.
      buildInputs = [ python-with-all-packages ] ++ (with pkgs; [
        gtk3 gtk-layer-shell cairo gobject-introspection libdbusmenu-gtk3
        gdk-pixbuf gnome-bluetooth cinnamon-desktop librsvg vte
      ]);

      dontUnpack = true; # Нам не нужны исходники

      # Фаза установки, которая в точности повторяет логику run-widget.nix
      installPhase = ''
        mkdir -p $out/bin
        # Создаем наш исполняемый файл
        cat > $out/bin/python-gtk-env << EOF
        #!${pkgs.stdenv.shell}
        # Захватываем переменные, подготовленные setup-hook'ами в среде сборки
        GI_TYPELIB_PATH="$GI_TYPELIB_PATH" \
        GDK_PIXBUF_MODULE_FILE="$GDK_PIXBUF_MODULE_FILE" \
        exec ${python-with-all-packages}/bin/python "\$@"
        EOF
        # Делаем его исполняемым
        chmod +x $out/bin/python-gtk-env
      '';
    };

in
{
  # --- ОСНОВНАЯ ЧАСТЬ ВАШЕЙ КОНФИГУРАЦИИ ---
  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  environment.systemPackages = with pkgs; [
    # Ваши основные утилиты
    neovim git telegram-desktop
    # Зависимости ax-shell
    brightnessctl cava cliphist gpu-screen-recorder-gtk hypridle hyprlock hyprpicker hyprshot hyprsunset imagemagick libnotify nvtopPackages.nvidia playerctl power-profiles-daemon swappy swww tesseract tmux unzip upower webp-pixbuf-loader wl-clipboard
    
    # Наши два кастомных пакета
    python-gtk-env
    fabric-cli-pkg
  ];
}
