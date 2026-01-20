{ pkgs, ... }:
let
  username = "dgingerich";
in
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };

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
    aws-vault
    claude-code
    colima
    devbox
    docker-buildx
    docker-client
    docker-compose
    granted
    uv
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "24.05";
}
