{ pkgs, username, ... }:

{
      environment.systemPackages = with pkgs; [
        vim
      ];

      nix.settings.experimental-features = "nix-command flakes";

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
          "splice"
          "steam"
          "tailscale"
          "vlc"
          "wezterm"
          "zotero"
        ];
      };

      programs.fish.enable = true;
      environment.shells = [
        pkgs.fish
      ];
      # system.activationScripts.setFishAsShell.text = ''
      #   chsh -s ${pkgs.fish} ${username}
      # '';

      users.users = {
        ${username} = {
          home = "/Users/${username}";
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

      system.defaults.controlcenter.Bluetooth = true;

      system.defaults.trackpad.Clicking = true;

      security.pam.enableSudoTouchIdAuth = true;

      system.stateVersion = 5;
      nixpkgs.hostPlatform = "x86_64-darwin";
    }
