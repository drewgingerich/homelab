{ pkgs, ... }:

{
  imports = [
    ../../modules/system
    ./users/dgingerich.nix
  ];

  networking.hostName = "m-dgingerich";

  environment.systemPackages = with pkgs; [
    vim
  ];

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
  system.defaults.NSGlobalDomain.KeyRepeat = 2;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 15;
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";

  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 5;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = ".hm.bak";
  nix.enable = false;
  nixpkgs.config.allowUnfree = true;
}
