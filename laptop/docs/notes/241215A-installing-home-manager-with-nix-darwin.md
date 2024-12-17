# Install home-manager

I want to use [home-manager](https://github.com/nix-community/home-manager) to set up my user configuration.
This separates my user config from my system config, 
which will allow me to reuse my user config across different systems.

In this case, I can [install `home-manager` as a `nix-darwin` module](https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-nix-darwin-module):

```nix
{
  description = "Darwin configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, home-manager, darwin, ... }: {
    darwinConfigurations = {
      some-hostname = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        modules = [
          ./configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.some-user = import ./home.nix;
          }
        ];
      };
    };
  };
}
```

The function `home-manager.darwinModules.home-manager` formats the `home-manager` configuration as a `nix-darwin` module.

Setting `home-manager.useGlobalPkgs = true` makes `home-manager` use `nix-darwin`'s instance of `nixpkgs`, 
which eliminates some redundancy and improves consistency when using `home-manager` via `nix-darwin`.

The `home-manager.useUserPackages` syncs user packages installed via `home-manager` and via `nix-darwin`'s `user.user` modules.
I don't know the details of this connections, whether it's `home-manager`'s installing packages by injecting it's own into `user.user`, 
or if `home-manager` is reading and including packages from `user.user`, or if it's something else.
Documentation is spares and [the source code](https://github.com/nix-community/home-manager/blob/66c5d8b62818ec4c1edb3e941f55ef78df8141a8/nixos/common.nix#L100-L105) is hard to read.

After creating a minimal `home-manager` configuration, I tried to rebuild but got an error:

```sh
error: A definition for option `home-manager.users.drew.home.homeDirectory' is not of type `path'. Definition values:
- In `/nix/store/6njjywmz7rwbzml9jfb3i9g63il1lc2z-source/nixos/common.nix': null
```

When disabling `home-manager.useUserPackages`, the error changed:

```sh
error: attribute 'drew' missing
at /nix/store/6njjywmz7rwbzml9jfb3i9g63il1lc2z-source/nixos/common.nix:34:27:
    33|
    34|           home.username = config.users.users.${name}.name;
      |                           ^
    35|           home.homeDirectory = config.users.users.${name}.home;
```

After some Googling, I realized that this was because I hadn't declared the user my `nix-darwin` config,
which was necessary when running `home-manager` as a `nix-darwin` module:

```nix
users.users = {
  drew = {
    home = /Users/drew;
  };
};
# And more nix-darwin configuration...
```

With that, `home-manager` was up and running via `nix-darwin`.

