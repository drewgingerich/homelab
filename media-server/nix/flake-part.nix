{ inputs, ... }:
{
  flake.nixosConfigurations.dusty-media-server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
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
