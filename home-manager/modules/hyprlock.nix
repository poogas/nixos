# /etc/nixos/home-manager/modules/hyprlock.nix
{ ... }:

{
  # Создаем файл конфигурации для hyprlock
  home.file.".config/hypr/hyprlock.conf".text = ''
    background {
        path = screenshot
        blur_passes = 3
        blur_size = 8
    }

    input-field {
        monitor =
        size = 250, 60
        outline_thickness = 2
        dots_size = 0.2 # Scale of input-field dots
        dots_spacing = 0.2 # Spacing between dots
        dots_center = true
        fade_on_empty = false
        font_color = rgb(202, 211, 245)
        inner_color = rgb(30, 30, 46)
        outer_color = rgb(137, 180, 250)
        rounding = -1
        placeholder_text = <i>Password...</i>
    }

    label {
        monitor =
        text = cmd[update:1000] echo "<b><big> $(date +"%H:%M") </big></b>"
        color = rgba(255, 255, 255, 0.8)
        font_size = 90
        position = 0, 200
        halign = center
        valign = top
    }
  '';
}
