{ inputs, ... }:
{
  flake.nixosConfigurations.lost-laptop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      # system
      inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
      inputs.home-manager.nixosModules.home-manager
      inputs.self.nixosModules.nixConfig
      inputs.self.nixosModules.backup
      inputs.self.nixosModules.keyboard
      inputs.self.nixosModules.mouse

      # CLI
      inputs.self.nixosModules.containers
      inputs.self.nixosModules.fish

      # apps
      inputs.self.nixosModules.steam
      ./configuration.nix
    ];
  };
}
