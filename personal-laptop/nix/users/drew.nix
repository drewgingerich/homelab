{ pkgs, ... }:
let
  username = "drew";
in
{
  users.users.${username} = {
    home = "/home/${username}";
    isNormalUser = true;
    description = "Drew Gingerich";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
    initialPassword = username;
  };

  security.sudo.extraRules = [
    {
      users = [ username ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  programs.steam.enable = true;

  home-manager.users.${username} = {
    custom = {
      cliTools.enable = true;
      fish.enable = true;
      git.enable = true;
      nvim.enable = true;
      starship.enable = true;
      wezterm.enable = true;
    };

    programs.firefox = {
      enable = true;
      profiles = {
        default = {
          id = 0;
          name = "default";
          isDefault = true;
          settings = {
            "signon.rememberSignons" = false;
            "widget.use-xdg-desktop-portal.file-picker" = 1;
            "browser.aboutConfig.showWarning" = false;
            "browser.compactmode.show" = true;
          };
          search = {
            force = true;
            default = "Kagi";
            engines = {
              "Kagi" = {
                urls = [
                  {
                    template = "https://kagi.com/search?";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
              };
            };
          };
        };
      };
    };

    programs.home-manager.enable = true;
    home.stateVersion = "25.11";
  };
}
