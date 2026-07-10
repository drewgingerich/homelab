{ inputs, ... }:
{
  flake.nixosConfigurations.unremarkable-game-server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-hardware.nixosModules.common-pc-ssd
      inputs.home-manager.nixosModules.home-manager
      inputs.self.nixosModules.nixConfig
      ./configuration.nix
    ];
  };
}
