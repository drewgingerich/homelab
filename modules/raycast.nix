{ inputs, ... }:
{
  flake.homeModules.raycast =
    { pkgs, lib, osConfig, ... }:
    lib.mkMerge [
      { home.packages = [ pkgs.raycast ]; }
      (lib.mkIf (!osConfig.home-manager.useGlobalPkgs) {
        nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "raycast" ];
      })
    ];

  flake.darwinModules.raycast =
    { lib, ... }:
    {
      home-manager.sharedModules = [ inputs.self.homeModules.raycast ];
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "raycast" ];
    };
}
