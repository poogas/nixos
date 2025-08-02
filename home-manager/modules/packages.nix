{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zip xz unzip p7zip ripgrep jq yq-go eza fzf mtr iperf3 dnsutils ldns
    aria2 socat nmap ipcalc cowsay file which tree gnused gnutar gawk
    zstd gnupg nix-output-monitor hugo glow btop iotop iftop strace
    ltrace lsof sysstat lm_sensors ethtool pciutils usbutils python311
  ];
}
