{ inputs, ... }:
{
  flake.homeModules.git =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options = {
        custom.git.enable = lib.mkEnableOption "Git";
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
          lfs.enable = true;
          settings = {
            user = {
              name = config.custom.git.userName;
              email = config.custom.git.userEmail;
            };
            pull = {
              ff = "only";
            };
            push = {
              authSetupRemote = "true";
              autoSetupRemote = "true";
            };
            init = {
              defaultBranch = "main";
            };
            fetch = {
              prune = "true";
            };
            merge = {
              conflictstyle = "diff3";
            };
            diff = {
              colorMoved = "default";
            };
          };
        };

        programs.delta = {
          enable = true;
          enableGitIntegration = true;
        };
      };
    };

  flake.nixosModules.git =
    { ... }:
    {
      home-manager.sharedModules = [ inputs.self.homeModules.git ];
    };
}
