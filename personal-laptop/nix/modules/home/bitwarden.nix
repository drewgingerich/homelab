{ pkgs, ... }:
let
  # newBwSession= pkgs.writeShellApplication {
  #   name = "new-bw-session";
  #   runtimeInputs = with pkgs; [libsecret bitwarden-cli fuzzel];
  #   text = ''
  #     BW_SESSION=$(secret-tool lookup bw-fuz bw-session-key || echo -n "")
  #     export BW_SESSION
  #     if ! bw unlock --check > /dev/null; then
  #       bw_password=$(fuzzel --dmenu --password)
  #       BW_SESSION=$(bw unlock "$bw_password" --raw)
  #       echo -n "$BW_SESSION" | secret-tool store --label "bw-fuz" bw-fuz bw-session-key
  #     fi
  #     echo -n "$BW_SESSION"
  #   '';
  # };
  #
  # newBwSelect = pkgs.writeShellApplication {
  #   name = "new-bw-select";
  #   runtimeInputs = with pkgs; [newBwSession libsecret bitwarden-cli fuzzel];
  #   text = ''
  #     item_type=$1
  #     BW_SESSION=$(new-bw-session)
  #     export BW_SESSION
  #     bw_items=$(bw list items | jq --raw-output '.[] | .id + "\t" + .name')
  #     item_id=$(echo -n "$bw_items" | fuzzel --dmenu --hide-prompt --with-nth 2 --accept-nth 1 --minimal-lines)
  #     echo -n "$item_id" | secret-tool store --label "bw-fuz login" bw-fuz "$item_type"
  #   '';
  # };
  #
  # newBwGet= pkgs.writeShellApplication {
  #   name = "new-bw-get";
  #   runtimeInputs = with pkgs; [libsecret bitwarden-cli];
  #   text = ''
  #     item_type="$1"
  #     item_field="$2"
  #     BW_SESSION=$(new-bw-session)
  #     export BW_SESSION
  #     item_id=$(secret-tool lookup bw-fuz "$item_type")
  #     bw get "$item_field" "$item_id"
  #   '';
  # };
  #
  # newBwPaste = pkgs.writeShellApplication {
  #   name = "new-bw-paste";
  #   runtimeInputs = with pkgs; [libsecret bitwarden-cli];
  #   text = ''
  #     echo -n "$1" | wl-copy --paste-once
  #     wtype -P XF86Paste
  #   '';
  # };
   
  bwSync = pkgs.writeShellApplication {
    name = "bw-sync";
    runtimeInputs = with pkgs; [rbw];
    text = ''
      rbw unlock
      rbw sync
    '';
  };

  bwSelect = pkgs.writeShellApplication {
    name = "bw-select";
    runtimeInputs = [pkgs.libsecret bwSync pkgs.rbw pkgs.fuzzel];
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
    runtimeInputs = [pkgs.rbw bwSelect];
    text = ''
      item_type=$1
      item_id=$(secret-tool lookup bw-fuz "$item_type")
      rbw get --raw "$item_id"
    '';
  };

  bwTotp= pkgs.writeShellApplication {
    name = "bw-totp";
    runtimeInputs = [pkgs.rbw pkgs.oath-toolkit bwSelect];
    text = ''
      totp_secret=$(bw-get login | jq -r '.data.totp')
      oathtool --base32 --totp "$totp_secret" -d 6
    '';
  };

  bwOpen = pkgs.writeShellApplication {
    name = "bw-open";
    runtimeInputs = [pkgs.rbw bwSelect bwGet];
    text = ''
      bw-select login
      bw-get login | jq -r '.data.uris[0]' | xargs xdg-open
    '';
  };

  bwPaste = pkgs.writeShellApplication {
    name = "bw-paste";
    runtimeInputs = [pkgs.wl-clipboard pkgs.wtype];
    text = ''
      echo -n "$1" | wl-copy --paste-once
      wtype -P XF86Paste
    '';
  };
in
{
  programs.rbw = {
    enable = true;
    settings = {
      email = "bitwarden@elsewhere.space";
      pinentry = pkgs.pinentry-qt;
    };
  };

  xdg.configFile = {
    "wlr-which-key" = {
      source = ../../../../dotfiles/wlr-which-key;
    };
  };

  home.packages = with pkgs; [
    bitwarden-cli
    bitwarden-desktop
    fuzzel
    libsecret
    rbw
    wlr-which-key
    wtype

  ] ++ [
    bwSync
    bwSelect
    bwGet
    bwTotp
    bwOpen
    bwPaste
  ];
}

