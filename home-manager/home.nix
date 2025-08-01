# home-manager/home.nix
{ stateVersion, hyprland-pkg, ... }:

{ config, pkgs, ... }:

{
  home.username = "qwerty";
  home.homeDirectory = "/home/qwerty";

  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprland-pkg;

    settings = {
      # --- МИНИМАЛЬНАЯ, ГАРАНТИРОВАННО РАБОЧАЯ КОНФИГУРАЦИЯ ---
      env = "XCURSOR_SIZE,24";

      input = {
        kb_layout = "us,ru";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 1;
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      # Убираем все сомнительные опции. Оставляем только самое базовое.
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };
      
      animations = {
        enabled = true;
      };

      # Привязки клавиш
      "$mainMod" = "SUPER";
      bind = [
        "$mainMod, Q, exec, alacritty"
        "$mainMod, C, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, dolphin"
        "$mainMod, V, togglefloating,"
        "$mainMod, R, exec, wofi --show drun"
        "$mainMod, P, pseudo,"
        "$mainMod, J, togglesplit,"
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
      ];

      # Автозапуск
      exec-once = [
        "waybar"
        "swayidle -w"
      ];
    };
  };

  # Остальные ваши настройки
  programs.waybar.enable = true;

  home.packages = with pkgs; [
    zip xz unzip p7zip ripgrep jq yq-go eza fzf mtr iperf3 dnsutils ldns
    aria2 socat nmap ipcalc cowsay file which tree gnused gnutar gawk
    zstd gnupg nix-output-monitor hugo glow btop iotop iftop strace
    ltrace lsof sysstat lm_sensors ethtool pciutils usbutils
  ];

  programs.git = { enable = true; userName = "qwerty"; userEmail = "temp@qwerty.qq"; };
  programs.starship = { enable = true; settings = { add_newline = false; aws.disabled = true; gcloud.disabled = true; line_break.disabled = true; }; };
  programs.alacritty = { enable = true; settings = { env.TERM = "xterm-256color"; font = { size = 12; draw_bold_text_with_bright_colors = true; }; scrolling.multiplier = 5; selection.save_to_clipboard = true; }; };

  home.stateVersion = "25.05";
}
