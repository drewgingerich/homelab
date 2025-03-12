{ config, ... }:

{
  nixpkgs.config.allowUnfree = true;
  boot.kernelParams = [ "module_blacklist=amdgpu" ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.enableRedistributableFirmware = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };
}
