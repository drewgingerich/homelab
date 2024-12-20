{ pkgs, ... }:

{
      environment.systemPackages = [
        pkgs.vim
      ];

      nix.settings.experimental-features = "nix-command flakes";

      homebrew = {
        enable = true;
        casks = [
          "blender"
          "docker"
          "discord"
          "firefox"
          "godot-mono"
          "inkscape"
          "krita"
          "obs"
          "obsidian"
          "rectangle"
          "steam"
          "tailscale"
          "vlc"
          "wezterm"
          "zotero"
        ];
      };

      programs.fish.enable = true;

      users.users = {
        drew = {
          home = /Users/drew;
        };
      };

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

      system.defaults.trackpad.Clicking = true;

      system.keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };

      security.pam.enableSudoTouchIdAuth = true;

      system.stateVersion = 5;
      nixpkgs.hostPlatform = "x86_64-darwin";
    }
