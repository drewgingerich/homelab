{ inputs, ... }:
{
  flake.nixosConfigurations.unremarkable-game-server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      inputs.nixos-hardware.nixosModules.common-pc-ssd
      inputs.home-manager.nixosModules.home-manager
      inputs.self.nixosModules.fish
      inputs.self.nixosModules.gnome
      inputs.self.nixosModules.nixConfig
      inputs.self.nixosModules.pcvr
      inputs.self.nixosModules.steam
      inputs.self.nixosModules.nvidiaGpu
      ./configuration.nix
    ];
  };
}
