{ inputs, ... }:
{
  flake.nixosConfigurations.lost-laptop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # system
      inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
      inputs.home-manager.nixosModules.home-manager
      inputs.self.nixosModules.nixConfig
      inputs.self.nixosModules.backup
      inputs.self.nixosModules.keyboard

      # CLI
      inputs.self.nixosModules.cliTools
      inputs.self.nixosModules.containers
      inputs.self.nixosModules.fish
      inputs.self.nixosModules.git
      inputs.self.nixosModules.nvim
      inputs.self.nixosModules.ssh-home-config
      inputs.self.nixosModules.starship

      # apps
      inputs.self.nixosModules.bitwarden
      inputs.self.nixosModules.qutebrowser
      inputs.self.nixosModules.steam
      inputs.self.nixosModules.wezterm
      ./configuration.nix
    ];
  };
}
