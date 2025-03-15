{ pkgs, ... }:
{
  users.users.drew = {
    home = "/Users/drew";
  };

  home-manager.users.drew = {
    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
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
    imports = [
      ../../../nix/user/programs/autorestic.nix
      ../../../nix/user/programs/fish.nix
      ../../../nix/user/programs/git.nix
      ../../../nix/user/programs/karabiner.nix
      ../../../nix/user/programs/nvim.nix
      ../../../nix/user/programs/starship.nix
      ../../../nix/user/programs/wezterm.nix
    ];
  };
}
