{ pkgs, ... }:
let
  username = "dreamy";
in
{
  users.users.${username} = {
    home = "/home/${username}";
    isNormalUser = true;
    shell = pkgs.fish;
    initialPassword = "";
  };

  home-manager.users.${username} = {
    custom = {
      cliTools.enable = true;
      fish.enable = true;
      git.enable = true;
      gnome.noOverview = true;
      nvim.enable = true;
      pcvr.enable = true;
      starship.enable = true;
      steam.enable = true;
      wezterm.enable = true;
    };

    home.packages = with pkgs; [
      cemu
      xivlauncher
    ];

    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
  };
}
