{ inputs, ... }:
{
  flake.homeModules.obsidian =
    { lib, osConfig, ... }:
    lib.mkMerge [
      { programs.obsidian.enable = true; }
      (lib.mkIf (!osConfig.home-manager.useGlobalPkgs) {
        nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "obsidian" ];
      })
    ];

  flake.nixosModules.obsidian =
    { lib, ... }:
    {
      home-manager.sharedModules = [ inputs.self.homeModules.obsidian ];
      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "obsidian"
        ];
    };

  flake.darwinModules.obsidian =
    { lib, ... }:
    {
      home-manager.sharedModules = [ inputs.self.homeModules.obsidian ];
      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "obsidian"
        ];
    };
}
