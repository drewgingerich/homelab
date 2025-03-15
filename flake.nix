{
  description = "System configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nix-darwin,
    home-manager,
    nixpkgs,
    ...
  }: {
    nixosConfigurations.unremarkable-game-server = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        ./game-server/nix/configuration.nix
      ];
    };
    darwinConfigurations.unremarkable-macbook-pro = nix-darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      modules = [
        home-manager.darwinModules.home-manager
        ./laptop/nix/configuration.nix
      ];
    };
  };
}
