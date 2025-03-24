{ config, pkgs, lib, ... }:
{
  options.custom.git.enable = lib.mkEnableOption "Configure Git for this user";

  config = lib.mkIf config.custom.git.enable {
    home.packages = with pkgs; [
      delta
      git
      git-lfs
      gh
      glab
      lazygit
    ];

    home.file = {
      ".gitconfig" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/git/.gitconfig";
      };
    };
  };
}
