{ inputs, ... }:
{
  flake.homeModules.cliTools =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options.custom.cliTools.enable = lib.mkEnableOption "CLI tools";

      config = lib.mkIf config.custom.cliTools.enable {
        home.packages = with pkgs; [
          bat
          btop
          cue
          eza
          direnv
          dust
          fd
          ffmpeg
          fselect
          fzf
          gcc
          gnupg
          hyperfine
          imagemagick
          jq
          pandoc
          ripgrep
          tealdeer
          unixtools.watch
          wget
          xh
          yazi
          yq
          zoxide
        ];
      };
    };

  flake.nixosModules.cliTools =
    { ... }:
    {
      home-manager.sharedModules = [ inputs.self.homeModules.cliTools ];
    };
}
