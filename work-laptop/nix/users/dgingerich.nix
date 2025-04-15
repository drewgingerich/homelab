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
    bat
    eza
    devbox
    direnv
    fzf
    ffmpeg
    gnupg
    htop
    hyperfine
    imagemagick
    jq
    pandoc
    ripgrep
    tealdeer
    wget
    yq
    zoxide
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "24.05";
}
