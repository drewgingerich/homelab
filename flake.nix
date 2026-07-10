{
  description = "System configs";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports = [
          # hosts
          ./game-server/nix/flake-part.nix
          ./media-server/nix/flake-part.nix
          ./personal-laptop/nix/flake-part.nix
          ./work-laptop/nix/flake-part.nix

          # modules
          ./modules/karabiner-elements.nix
          ./modules/nix-config.nix
        ];
      }
    );
}
