# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/nvidia.nix
    ./modules/wivern.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "unremarkable-game-server";

  # Enable networking.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11.
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Desktop manager
  services.xserver.desktopManager.gnome.enable = true;

  # Display manager
  services.xserver.displayManager.gdm.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "dreamy";

  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.
  # https://discourse.nixos.org/t/stop-pc-from-sleep/5757/2
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.fish.enable = true;

  users.users = {
    ${username} = {
      home = "/home/${username}";
      isNormalUser = true;
      description = "Drew Gingerich";
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.fish;
      initialPassword = "${username}";
    };
    dreamy = {
      home = "/home/dreamy";
      isNormalUser = true;
      shell = pkgs.fish;
      initialPassword = "";
    };
  };

  security.sudo.extraRules = [{
    users = [ "${username}" ];
    commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
  }];


  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    cemu
    firefox
    google-chrome
    lshw
    tailscale
    vim
    xivlauncher
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
  };

  services.plex = {
    enable = true;
    openFirewall = true;
  };

  services.openssh.enable = true;

  services.tailscale.enable = true;

  system.stateVersion = "23.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
