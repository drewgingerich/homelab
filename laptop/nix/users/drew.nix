{ ... }:
let
  username = "drew";
in
{
  users.users.${username}= {
    home = "/Users/${username}";
  };

  home-manager.users.${username}= {
    imports = [
      ../../../modules/home
    ];

    custom = {
      autorestic.enable = true;
      cliTools.enable = true;
      fish.enable = true;
      git.enable = true;
      karabiner.enable = true;
      nvim.enable = true;
      starship.enable = true;
      wezterm.enable = true;
    };

    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
  };
}
