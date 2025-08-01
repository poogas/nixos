{ username, ... }:

{
  programs.git = {
    enable = true;
    userName = username;
    userEmail = "temp@${username}.qq";
  };
}
