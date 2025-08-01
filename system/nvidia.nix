{ lib, pkgs, config, ... }:
with lib;

let
  cfg = config.drivers.nvidia;
in
{
  options.drivers.nvidia = {
    enable = mkEnableOption "Enable Nvidia Drivers";
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      open = true;

      package = config.boot.kernelPackages.nvidiaPackages.stable;

      modesetting.enable = true;
      nvidiaSettings = false;
      nvidiaPersistenced = false;

      powerManagement = {
        enable = false;
        finegrained = false;
      };
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau
        libva
        vdpauinfo
      ];
    };
  };
}
