{
  description = "System configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    {
      nixosConfigurations = {
        dusty-media-server = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            home-manager.nixosModules.home-manager
            ./media-server/nix/configuration.nix
          ];
        };
        unremarkable-game-server = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            home-manager.nixosModules.home-manager
            ./game-server/nix/configuration.nix
          ];
        };
        lost-laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            home-manager.nixosModules.home-manager
            ./personal-laptop/nix/configuration.nix
          ];
        };
      };
      darwinConfigurations = {
        unremarkable-macbook-pro = nix-darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [
            home-manager.darwinModules.home-manager
            ./laptop/nix/configuration.nix
          ];
        };
      };
      homeConfigurations = {
        work = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-darwin"; };
          modules = [ ./work-laptop/nix/users/dgingerich.nix ];
        };
      };
    };
}
