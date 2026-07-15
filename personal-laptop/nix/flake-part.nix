{ inputs, ... }:
{
  flake.nixosConfigurations.lost-laptop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
      inputs.home-manager.nixosModules.home-manager
      inputs.self.nixosModules.autorestic
      inputs.self.nixosModules.bitwarden
      inputs.self.nixosModules.cliTools
      inputs.self.nixosModules.containers
      inputs.self.nixosModules.keyboard
      inputs.self.nixosModules.fish
      inputs.self.nixosModules.git
      inputs.self.nixosModules.nixConfig
      inputs.self.nixosModules.nvim
      inputs.self.nixosModules.qutebrowser
      inputs.self.nixosModules.ssh-home-config
      inputs.self.nixosModules.starship
      inputs.self.nixosModules.steam
      inputs.self.nixosModules.wezterm
      ./configuration.nix
    ];
  };
}
