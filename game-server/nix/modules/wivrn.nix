{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.monado-vulkan-layers
  ];
  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
    autoStart = true;
  };
  hardware.graphics.extraPackages = [
    pkgs.monado-vulkan-layers
  ];
}
