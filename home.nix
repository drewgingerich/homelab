{ config, username, pkgs, ... }:
let
  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "24.05";

  imports = [
    ./nix/user/programs/autorestic.nix
    ./nix/user/programs/fish.nix
    ./nix/user/programs/git.nix
    ./nix/user/programs/karabiner.nix
    ./nix/user/programs/nvim.nix
    ./nix/user/programs/starship.nix
    ./nix/user/programs/wezterm.nix
  ];

  home.packages = with pkgs; [
    asdf-vm
    bat
    devbox
    direnv
    eza
    fzf
    ffmpeg
    gnupg
    helix
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
}
