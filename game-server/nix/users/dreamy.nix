{ pkgs, ... }:
{
  users.users.dreamy = {
    home = "/home/dreamy";
    isNormalUser = true;
    shell = pkgs.fish;
    initialPassword = "";
  };

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "dreamy";

  home-manager.users.dreamy = {
    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
    home.username = "dreamy";
    home.homeDirectory = "/home/dreamy";
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

    imports = [
      ../../../nix/user/programs/fish.nix
      ../../../nix/user/programs/git.nix
      ../../../nix/user/programs/nvim.nix
      ../../../nix/user/programs/starship.nix
      ../../../nix/user/programs/wezterm.nix
    ];
  };
}
