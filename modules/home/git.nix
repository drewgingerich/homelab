{ config, pkgs, lib, ... }:
{
  options = {
    custom.git.enable = lib.mkEnableOption "Configure Git for this user";
    custom.git.userName = lib.mkOption {
      type = lib.types.str;
      default = "Drew Gingerich";
    };
    custom.git.userEmail = lib.mkOption {
      type = lib.types.str;
      default = "drew@elsewhere.space";
    };
  };

  config = lib.mkIf config.custom.git.enable {
    home.packages = with pkgs; [
      gh
      glab
      lazygit
    ];

    programs.git = {
      enable = true;
      userName = config.custom.git.userName;
      userEmail = config.custom.git.userEmail;
      delta.enable = true;
      lfs.enable = true;
      extraConfig = {
        pull = { ff = "only"; };
        push = {
          authSetupRemote = "true";
          autoSetupRemote = "true";
        };
        init = { defaultBranch = "main"; };
        fetch = { prune = "true"; };
        merge = { conflictstyle = "diff3"; };
        diff = { colorMoved = "default"; };
      };
    };
  };
}
