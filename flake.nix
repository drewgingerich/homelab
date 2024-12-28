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
  }: let
    username = "drew";
  in {
    nixosConfigurations.unremarkable-game-server = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./game-server/nix/configuration.nix
      ];
    };
    darwinConfigurations.unremarkable-macbook-pro = nix-darwin.lib.darwinSystem {
      system = " x86_64-darwin";
      specialArgs = {
        username = "${username}";
      };
      modules = [
        ./laptop/nix/configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { username = "${username}"; };
          home-manager.users.${username} = import ./laptop/nix/home.nix;
        }
      ];
    };
  };
}
