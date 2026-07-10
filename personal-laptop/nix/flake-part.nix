{ inputs, ... }:
{
  flake.nixosConfigurations.lost-laptop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
      inputs.home-manager.nixosModules.home-manager
      inputs.self.nixosModules.nixConfig
      ./configuration.nix
    ];
  };
}
