{ username, homeStateVersion, ... }:

{
  imports = [
    ./modules
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = homeStateVersion;
}
