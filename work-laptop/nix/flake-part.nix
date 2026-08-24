{ inputs, ... }:
{
  flake.darwinConfigurations.m-dgingerich = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      inputs.home-manager.darwinModules.home-manager
      inputs.self.darwinModules.cliTools
      inputs.self.darwinModules.containers
      inputs.self.darwinModules.fish
      inputs.self.darwinModules.git
      inputs.self.darwinModules.keyboard
      inputs.self.darwinModules.nvim
      inputs.self.darwinModules.obsidian
      # inputs.self.darwinModules.raycast
      inputs.self.darwinModules.starship
      inputs.self.darwinModules.wezterm
      ./configuration.nix
    ];
  };
}
