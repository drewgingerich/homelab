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
      fish.enable = true;
      git.enable = true;
      nvim.enable = true;
      starship.enable = true;
      wezterm.enable = true;
      steam.enable = true;
      gnome.noOverview = true;
      # wivrn.enable = true;
    };

    home.packages = with pkgs; [
      bat
      cemu
      eza
      direnv
      ffmpeg
      fzf
      gnupg
      htop
      hyperfine
      imagemagick
      jq
      pandoc
      ripgrep
      tealdeer
      wget
      xivlauncher
      yq
      zoxide
    ];

    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
  };
}
