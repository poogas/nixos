{ hyprland-pkg, ax-shell-src, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprland-pkg;

    settings = {
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

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };

      };

      animations.enabled = true;

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
      exec-once = [
        "uwsm --app python-gtk-env ${ax-shell-src}/main.py"
       ];
    };
  };
  #
  # home.xdg.configFile."Ax-Shell/config.toml".text = builtins.readFile "${ax-shell-src}/config/config.toml";
  # home.xdg.configFile."Ax-Shell/style.css".text = builtins.readFile "${ax-shell-src}/config/style.css";
}
