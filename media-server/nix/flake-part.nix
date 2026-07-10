{ inputs, ... }:
{
  flake.nixosConfigurations.dusty-media-server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.home-manager.nixosModules.home-manager
      inputs.self.nixosModules.nixConfig
      ./configuration.nix
    ];
  };
}
