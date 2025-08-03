{ pkgs, ... }:

let
  # Шаг 1: Определяем все системные C-библиотеки, которые нам нужны.
  gtk-dependencies = with pkgs; [
    gtk3
    gobject-introspection
    cairo
    gdk-pixbuf
    gtk-layer-shell
    libdbusmenu-gtk3
    cinnamon-desktop
    gnome-bluetooth
    vte
  ];

  # Шаг 2: Создаем интерпретатор Python со всеми нужными ему Python-библиотеками.
  python-with-fabric = pkgs.python312.withPackages (ps: with ps; [
    python-fabric
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
  ]);

in
{
  # Эти настройки остаются без изменений
  programs.firefox.enable = true;
  programs.gpu-screen-recorder.enable = true;
  nixpkgs.config.allowUnfree = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # Список системных пакетов
  environment.systemPackages = with pkgs; [
    # Ваши основные утилиты
    neovim
    git
    telegram-desktop

    # Утилиты для ax-shell
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

    # ======================== ФИНАЛЬНОЕ РЕШЕНИЕ (makeWrapper) =======================
    # Шаг 3: Создаем derivation, который использует makeWrapper для создания обертки
    (stdenv.mkDerivation {
      name = "python-with-ax-shell-env";
      nativeBuildInputs = [ makeWrapper ]; # Указываем, что нам нужен makeWrapper
      dontUnpack = true; # Нам не нужны исходники, мы просто создаем скрипт

      # Команды, которые будут выполнены для "сборки" нашего пакета
      installPhase = ''
        mkdir -p $out/bin
        makeWrapper ${python-with-fabric}/bin/python $out/bin/python-with-ax-shell-env \
          --prefix GI_TYPELIB_PATH : "${lib.makeSearchPathOutput "lib/girepository-1.0" gtk-dependencies}" \
          --prefix XDG_DATA_DIRS : "${lib.makeSearchPath "share" gtk-dependencies}"
      '';
    })
    # ==============================================================================
  ];
}
