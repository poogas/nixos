{ username, ... }:

{
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.trusted-users = [ "root" username ];

  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
}
