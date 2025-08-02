{ pkgs, ... }:

let
  # Создаем специальную сборку Python со всеми необходимыми пакетами
  ax-shell-python = pkgs.python3.withPackages (ps: with ps; [
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

  # Скачиваем исходный код Ax-Shell из GitHub
  ax-shell-src = pkgs.fetchFromGitHub {
    owner = "Axenide";
    repo = "Ax-Shell";
    rev = "a6094b83d1c16f2c0022d4f84da63e6e7300c028"; # Последний коммит на 1 августа 2025
    hash = "sha256-R8w0bWqbrq4zSzsY4z7/u/qUu8I+V/tK2M80eS3LgJ4=";
  };

in
{
  home.packages = with pkgs; [
    # 1. Основные зависимости Ax-Shell
    # Утилиты и демоны для рабочего стола
    brightnessctl
    cava
    cliphist
    gnome-bluetooth-3_0  # Для поддержки Bluetooth
    gobject-introspection # Необходимо для PyGObject
    gpu-screen-recorder
    grimblast            # Утилита для скриншотов
    hypridle             # Демон бездействия для Hyprland
    hyprlock             # Экран блокировки
    hyprpicker           # Выбор цвета
    imagemagick
    libnotify            # Для отправки уведомлений
    matugen              # Генератор цветовых схем
    nvtop                # Мониторинг GPU (для NVIDIA)
    playerctl            # Управление плеерами
    swappy               # Редактор скриншотов
    swww                 # Управление обоями
    (tesseract.with-langs [ "eng" "rus" ]) # Распознавание текста
    tmux
    upower
    vte                  # Виджет терминала (зависимость)
    webp-pixbuf-loader
    wlinhibit

    # 2. Python с нужными пакетами
    ax-shell-python

    # 3. Шрифты
    (nerdfonts.override { fonts = [ "ZedMono" ]; }) # Zed Sans (как часть Nerd Fonts)
    tabler-icons
  ];

  # 4. Добавляем скрипт запуска в автозагрузку Hyprland
  wayland.windowManager.hyprland.settings.exec-once = [
    # Запускаем основной скрипт Ax-Shell
    # Путь к скрипту будет доступен, так как мы "установили" его через home.packages
    "bash -c 'exec ${ax-shell-python}/bin/python ${ax-shell-src}/main.py &> /dev/null &'"
  ];
}
