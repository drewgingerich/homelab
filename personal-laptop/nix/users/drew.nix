{
  inputs,
  pkgs,
  config,
  ...
}:
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

  custom.backups = {
    drewData = {
      paths = [ "${config.users.users.${username}.home}/data" ];
      excludes = [ ".git" ];
    };
  };

  home-manager.users.${username} = {
    imports = [
      inputs.self.homeModules.cliTools
      inputs.self.homeModules.fish
      inputs.self.homeModules.git
      inputs.self.homeModules.nvim
      inputs.self.homeModules.personalSshConfig
      inputs.self.homeModules.qutebrowser
      inputs.self.homeModules.starship
      inputs.self.homeModules.wezterm
    ];

    custom = {
      bitwarden.enable = true;
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
            default = "udm14";
            engines = {
              "udm14" = {
                urls = [
                  {
                    template = "https://www.google.com/search?";
                    params = [
                      {
                        name = "udm";
                        value = "14";
                      }
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

    programs.obs-studio.enable = true;

    home.packages = with pkgs; [
      limo
      mgba
      melonds
      openmw

      wineWow64Packages.waylandFull

      lm_sensors
      acpitool

      discord
      easyeffects
      inkscape
      krita
      obsidian
      signal-desktop
      tenacity
      wl-clipboard
      zotero
    ];

    programs.home-manager.enable = true;
    home.stateVersion = "26.05";
  };
}
