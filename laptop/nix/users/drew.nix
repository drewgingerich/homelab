{ pkgs, ... }:
let
  username = "drew";
in
{
  users.users.drew = {
    home = "/Users/drew";
  users.users.${username}= {
    home = "/Users/${username}";
  };

  home-manager.users.drew = {
  home-manager.users.${username}= {
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
      bat
      eza
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
  };
}
