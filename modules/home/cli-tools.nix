{ pkgs, lib, config, ... }:
{
  options.custom.cliTools.enable = lib.mkEnableOption "Install CLI tools for this user";

  config = lib.mkIf config.custom.cliTools.enable {
    home.packages = with pkgs; [
      bat
      btop
      eza
      direnv
      fzf
      ffmpeg
      gnupg
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
  };
}
