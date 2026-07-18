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

  home-manager.users.${username} = {
    custom = {
      bitwarden.enable = true;
      cliTools.enable = true;
      fish.enable = true;
      git.enable = true;
      nvim.enable = true;
      qutebrowser.enable = true;
      ssh-home-config.enable = true;
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
      mgba
      melonds

      wineWow64Packages.waylandFull

      lm_sensors
      acpitool

      bitwarden-cli
      bitwarden-desktop
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
