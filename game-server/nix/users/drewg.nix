{ pkgs, ... }:
let
  username = "drewg";
in
{
  users.users.${username} = {
    home = "/home/${username}";
    isNormalUser = true;
    description = "Drew Gingerich";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    initialPassword = username;
  };

  security.sudo.extraRules = [{
    users = [ username ];
    commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
  }];

  home-manager.users.${username} = {
    custom = {
      cliTools.enable = true;
      fish.enable = true;
      git.enable = true;
      nvim.enable = true;
      starship.enable = true;
      wezterm.enable = true;
    };

    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
  };
}
