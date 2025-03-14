{ config, ... }:
{
  xdg.configFile = {
    "karabiner" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/karabiner";
    };
  };
}
