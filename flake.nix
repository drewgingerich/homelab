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
      specialArgs = { username = "drewg"; };
      modules = [
        ./game-server/nix/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { username = "drewg"; };
          home-manager.backupFileExtension = ".hm.bak";
          home-manager.users.drewg = import ./home.nix;
        }
      ];
    };
    darwinConfigurations.unremarkable-macbook-pro = nix-darwin.lib.darwinSystem {
      system = " x86_64-darwin";
      specialArgs = { username = "drew"; };
      modules = [
        ./laptop/nix/configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { username = "drew"; };
          home-manager.backupFileExtension = ".hm.bak";
          home-manager.users.drew = import ./home.nix;
        }
      ];
    };
  };
}
