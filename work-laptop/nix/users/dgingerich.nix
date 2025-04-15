{ pkgs, ... }:
let
  username = "dgingerich";
in
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  imports = [
    ../../../modules/home
  ];

  custom = {
    cliTools.enable = true;
    fish.enable = true;
    git = {
      enable = true;
      userEmail = "dgingerich@ithaka.org";
    };
    karabiner.enable = true;
    nvim.enable = true;
    starship.enable = true;
    wezterm.enable = true;
  };

  home.packages = with pkgs; [
    asdf-vm
    awscli2
    devbox
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "24.05";
}
