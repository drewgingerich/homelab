{ ... }:
{
  flake.homeModules.cliTools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        bat
        busybox
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
        xh
        yazi
        yq
        zoxide
      ];
    };
}
