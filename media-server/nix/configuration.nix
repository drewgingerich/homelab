{ pkgs, ... }:
{
  imports = [
    ../../modules/system
    ./modules
    ./users
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/wwn-0x500a0751e1f50c03";

  networking.hostName = "dusty-media-server";
  networking.networkmanager.enable = true;
  networking.hostId = "5c767c90";
  networking.nameservers = [
    "9.9.9.9"
    "149.112.112.112"
  ];
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 32400 ];
  };

  time.timeZone = "America/Los_Angeles";

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

  environment.systemPackages = with pkgs; [
    docker
    git
    lshw
    tailscale
    vim
    zellij
  ];

  boot.supportedFilesystems.zfs = true;
  boot.zfs.extraPools = [ "wish" ];
  services.zfs.autoScrub.enable = true;

  services.openssh.enable = true;

  services.tailscale.enable = true;

  virtualisation.docker.enable = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = ".hm.bak";
  system.stateVersion = "25.11";
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
