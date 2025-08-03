{ pkgs, ... }:

{
  programs.firefox.enable = true;
  programs.gpu-screen-recorder.enable = true;
  nixpkgs.config.allowUnfree = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
    git
    telegram-desktop

    # ax-shell
    brightnessctl #+
    cava #+
    cliphist #+ 
    gobject-introspection #?
    gpu-screen-recorder-gtk #+
    hypridle #?
    hyprlock #?
    hyprpicker #?
    hyprshot #?
    hyprsunset #?
    imagemagick #+
    libnotify #+
    nvtopPackages.nvidia #+
    playerctl #+
    power-profiles-daemon #?
    swappy #+
    swww #+
    tesseract #+
    tmux #+
    unzip #+
    upower #+
    vte #?
    webp-pixbuf-loader #?
    wl-clipboard #+

    (python3.withPackages (ps: with ps; [
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
    ]))
  ];
}
