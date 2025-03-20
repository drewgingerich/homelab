{ pkgs, ... }:
let
  username = "dgingerich";
in
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";

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

  imports = [
    ../../../nix/user/programs/fish.nix
    ../../../nix/user/programs/karabiner.nix
    ../../../nix/user/programs/nvim.nix
    ../../../nix/user/programs/starship.nix
    ../../../nix/user/programs/wezterm.nix
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "24.05";
}
