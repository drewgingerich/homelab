{
  description = "System configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      home-manager,
      nixos-hardware,
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
            nixos-hardware.nixosModules.framework-amd-ai-300-series
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
        dgingerich-ithaka-mbp = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            home-manager.darwinModules.home-manager
            ./work-laptop/nix/configuration.nix
          ];
        };
      };
    };
}
