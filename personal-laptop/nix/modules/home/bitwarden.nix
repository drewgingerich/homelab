{ config, pkgs, ... }:
let
  bwStateDir = "${config.xdg.stateHome}/bw";

  bwSelect = pkgs.writeShellApplication {
    name = "bw-select";
    runtimeInputs = with pkgs; [rbw fuzzel];
    text = ''
      item_type=$1
      rbw unlock
      rbw sync
      item=$(rbw list | fuzzel --dmenu --hide-prompt --minimal-lines)
      mkdir -p "${bwStateDir}"
      echo "$item" > "${bwStateDir}/$item_type"
    '';
  };

  bwOpen = pkgs.writeShellApplication {
    name = "bw-open";
    runtimeInputs = [pkgs.rbw bwSelect];
    text = ''
      bw-select login
      item=$(cat "${bwStateDir}/login")
      rbw get "$item" --field uris | head -n 1 | xargs xdg-open
    '';
  };

  bwPaste = pkgs.writeShellApplication {
    name = "bw-paste";
    runtimeInputs = with pkgs; [rbw wtype wl-clipboard];
    text = ''
      item_type="$1"
      item_field="$2"
      item=$(cat "${bwStateDir}/$item_type")
      rbw get "$item" --field "$item_field" | head -n 1 | wl-copy --paste-once
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
    rbw
    wlr-which-key
    wtype
  ] ++ [
    bwSelect
    bwPaste
    bwOpen
  ];
}

