{ pkgs, username, ... }:

{
  users.users."${username}" = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    shell = pkgs.bash;
  };
}
