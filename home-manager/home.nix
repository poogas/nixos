# home-manager/home.nix
{ config, pkgs, ... }:

{
  home.username = "qwerty";
  home.homeDirectory = "/home/qwerty";

  # Удаляем специфичные для X11 настройки
  # xresources.properties = { ... }; # <<< ЭТО БОЛЬШЕ НЕ РАБОТАЕТ В WAYLAND

  # Новая секция для Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    # Используем тот же пакет, что и в системе для консистентности
    package = config.programs.hyprland.package;
    # Дополнительные настройки можно писать прямо здесь
    settings = {
      # Переменные окружения для сессии
      env = "XCURSOR_SIZE,24";

      # Устройства ввода
      input = {
        kb_layout = "us,ru";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 1;
      };
      
      # Основные настройки
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      # Декорации
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      # Анимации
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Привязки клавиш
      "$mainMod" = "SUPER"; # Клавиша Win/Super
      bind = [
        "$mainMod, Q, exec, alacritty" # Открыть терминал
        "$mainMod, C, killactive,"      # Закрыть активное окно
        "$mainMod, M, exit,"            # Выйти из Hyprland
        "$mainMod, E, exec, dolphin"    # Файловый менеджер (установите его, если нужно)
        "$mainMod, V, togglefloating,"  # Переключить плавающий режим
        "$mainMod, R, exec, wofi --show drun" # Запустить wofi
        "$mainMod, P, pseudo,"          # Псевдо-тайлинг
        "$mainMod, J, togglesplit,"     # Переключить dwindle/master layout

        # Перемещение фокуса
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Переключение рабочих столов
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"

        # Перемещение окон на рабочие столы
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
      ];

      # Автозапуск приложений при старте
      exec-once = [
        "waybar"                     # Запустить waybar
        "swayidle -w"                # Запустить swayidle
        # "swaybg -i path/to/wallpaper" # Установить обои, укажите путь
      ];
    };
  };

  # Конфигурация Waybar (пример)
  programs.waybar.enable = true;
  # Вы можете настроить его здесь или через home.file, чтобы создать ~/.config/waybar/config
  # ...

  # Пакеты, которые были у вас, все еще актуальны
  home.packages = with pkgs; [
    # ... ваши CLI утилиты ...
    ripgrep jq yq-go eza fzf ...
  ];
  
  # Остальные программы (git, starship, alacritty) остаются без изменений
  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "qwerty";
    userEmail = "temp@qwerty.qq";
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  programs.alacritty = {
    enable = true;
    # custom settings
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
        draw_bold_text_with_bright_colors = true;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

  home.stateVersion = stateVersion;
}
