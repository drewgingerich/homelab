{ inputs, ... }:
{
  flake.darwinConfigurations.m-dgingerich = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = { inherit inputs; };
    modules = [
      inputs.home-manager.darwinModules.home-manager
      inputs.self.darwinModules.containers
      inputs.self.darwinModules.fish
      inputs.self.darwinModules.keyboard
      inputs.self.darwinModules.nvim
      inputs.self.darwinModules.obsidian
      # inputs.self.darwinModules.raycast
      ./configuration.nix
    ];
  };
}
