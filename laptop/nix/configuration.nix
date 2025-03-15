{ pkgs, ... }:

{
  imports = [
    ./users/drew.nix
  ];

  environment.systemPackages = with pkgs; [
    vim
  ];

  homebrew = {
    enable = true;
    casks = [
      "ableton-live-suite@11"
      "blender"
      "docker"
      "discord"
      "firefox"
      "godot-mono"
      "google-chrome"
      "inkscape"
      "itch"
      "karabiner-elements"
      "krita"
      "launchcontrol"
      "logitech-g-hub"
      "moonlight"
      "obs"
      "obsidian"
      "raycast"
      "rectangle"
      "signal"
      "sony-ps-remote-play"
      "splice"
      "steam"
      "tailscale"
      "vlc"
      "wezterm"
      "zen-browser"
      "zotero"
    ];
  };

  programs.fish.enable = true;

  environment.shells = [
    pkgs.fish
  ];

  system.startup.chime = false;

  system.defaults.finder = {
    FXPreferredViewStyle = "Nlsv";
    ShowPathbar = true;
    AppleShowAllFiles = true;
    AppleShowAllExtensions = true;
    CreateDesktop = false;
    ShowExternalHardDrivesOnDesktop = false;
    ShowRemovableMediaOnDesktop = false;
    _FXShowPosixPathInTitle = true;
    _FXSortFoldersFirst = true;
    FXEnableExtensionChangeWarning = false;
    NewWindowTarget = "Home";
  };

  system.defaults.dock = {
    orientation = "right";
    tilesize = 32;
    autohide = true;
    autohide-delay = 0.0;
    autohide-time-modifier = 1.0;
    launchanim = false;
    persistent-apps = [];
    persistent-others = [];
    static-only = true;
    show-recents = false;
    showhidden = true;
    show-process-indicators = false;
    wvous-tl-corner = 1;
    wvous-bl-corner = 1;
    wvous-tr-corner = 1;
    wvous-br-corner = 1;
  };

  system.defaults.controlcenter.Bluetooth = true;

  system.defaults.trackpad.Clicking = true;

  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 5;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = ".hm.bak";
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.hostPlatform = "x86_64-darwin";
}
