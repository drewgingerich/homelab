{ inputs, ... }:
{
  flake.nixosConfigurations.dusty-media-server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      inputs.home-manager.nixosModules.home-manager
      inputs.self.nixosModules.containers
      inputs.self.nixosModules.fish
      inputs.self.nixosModules.git
      inputs.self.nixosModules.nixConfig
      inputs.self.nixosModules.nvim
      inputs.self.nixosModules.ssh-home-config
      ./configuration.nix
    ];
  };
}
