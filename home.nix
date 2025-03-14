{ config, username, pkgs, ... }:
let
  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "24.05";

  imports = [
    ./nix/user/programs/autorestic
    ./nix/user/programs/fish
    ./nix/user/programs/git
    ./nix/user/programs/karabiner
    ./nix/user/programs/nvim
    ./nix/user/programs/starship
    ./nix/user/programs/wezterm
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
