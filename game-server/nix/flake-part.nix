{ inputs, ... }:
{
  flake.nixosConfigurations.unremarkable-game-server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-hardware.nixosModules.common-pc-ssd
      inputs.home-manager.nixosModules.home-manager
      inputs.self.nixosModules.autorestic
      inputs.self.nixosModules.cliTools
      inputs.self.nixosModules.fish
      inputs.self.nixosModules.git
      inputs.self.nixosModules.nixConfig
      inputs.self.nixosModules.nvim
      inputs.self.nixosModules.qutebrowser
      inputs.self.nixosModules.ssh-home-config
      inputs.self.nixosModules.starship
      inputs.self.nixosModules.wezterm
      ./configuration.nix
    ];
  };
}
