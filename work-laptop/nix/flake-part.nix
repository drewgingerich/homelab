{ inputs, ... }:
{
  flake.darwinConfigurations.m-dgingerich = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      inputs.home-manager.darwinModules.home-manager
      inputs.self.darwinModules.keyboard
      inputs.self.darwinModules.containers
      ./configuration.nix
    ];
  };
}
