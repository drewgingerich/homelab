{ inputs, ... }:
{
  flake.homeModules.bitwarden =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      bwSync = pkgs.writeShellApplication {
        name = "bw-sync";
        runtimeInputs = with pkgs; [ rbw ];
        text = ''
          rbw unlock
          rbw sync
        '';
      };

      bwSelect = pkgs.writeShellApplication {
        name = "bw-select";
        runtimeInputs = [
          pkgs.libsecret
          bwSync
          pkgs.rbw
          pkgs.fuzzel
        ];
        text = ''
          item_type=$1
          bw-sync
          items=$(rbw list --fields id,name)
          item_id=$(echo -n "$items" | fuzzel --dmenu --hide-prompt --minimal-lines --with-nth 2 --accept-nth 1)
          echo -n "$item_id" | secret-tool store --label "bw-fuz" bw-fuz "$item_type"
        '';
      };

      bwGet = pkgs.writeShellApplication {
        name = "bw-get";
        runtimeInputs = [
          pkgs.rbw
          bwSelect
        ];
        text = ''
          item_type=$1
          item_id=$(secret-tool lookup bw-fuz "$item_type")
          rbw get --raw "$item_id"
        '';
      };

      bwTotp = pkgs.writeShellApplication {
        name = "bw-totp";
        runtimeInputs = [
          pkgs.rbw
          pkgs.oath-toolkit
          bwSelect
        ];
        text = ''
          totp_secret=$(bw-get login | jq -r '.data.totp')
          oathtool --base32 --totp "$totp_secret" -d 6
        '';
      };

      bwOpen = pkgs.writeShellApplication {
        name = "bw-open";
        runtimeInputs = [
          pkgs.rbw
          bwSelect
          bwGet
        ];
        text = ''
          bw-select login
          bw-get login | jq -r '.data.uris[0].uri' | xargs xdg-open
        '';
      };

      bwPaste = pkgs.writeShellApplication {
        name = "bw-paste";
        runtimeInputs = [
          pkgs.wl-clipboard
          pkgs.wtype
        ];
        text = ''
          echo -n "$1" | wl-copy --paste-once
          wtype -P XF86Paste
        '';
      };
    in
    {
      options.custom.bitwarden.enable = lib.mkEnableOption "Bitwarden";

      config = lib.mkIf config.custom.bitwarden.enable {
        assertions = [
          {
            assertion = pkgs.stdenv.isLinux;
            message = "Only works on Linux";
          }
        ];

        programs.rbw = {
          enable = true;
          settings = {
            email = "bitwarden@elsewhere.space";
            pinentry = pkgs.pinentry-qt;
          };
        };

        xdg.configFile = {
          "wlr-which-key" = {
            source = ../dotfiles/wlr-which-key;
          };
        };

        home.packages =
          with pkgs;
          [
            bitwarden-cli
            bitwarden-desktop
            fuzzel
            libsecret
            rbw
            wlr-which-key
            wtype
          ]
          ++ [
            bwSync
            bwSelect
            bwGet
            bwTotp
            bwOpen
            bwPaste
          ];
      };
    };

  flake.nixosModules.bitwarden =
    { ... }:
    {
      home-manager.sharedModules = [ inputs.self.homeModules.bitwarden ];
    };
}
