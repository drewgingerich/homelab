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
    autorestic.enable = true;
    fish.enable = true;
    git.enable = true;
    karabiner.enable = true;
    nvim.enable = true;
    starship.enable = true;
    wezterm.enable = true;
  };

  home.packages = with pkgs; [
    asdf-vm
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
