Configuration can be broken out into modules.
This can help with organization, though I don't know how I want to organize things yet.


```nix
{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, darwin, ... }: {
    darwinConfigurations = {
      some-hostname = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        modules = [ ./configuration.nix ];
      };
    };
  };
}
```

The [`lib.darwinSystem` function](https://github.com/LnL7/nix-darwin/blob/a35b08d09efda83625bef267eb24347b446c80b8/flake.nix#L17-L46) 
accepts files that implement the module interface of the [Nix module system](https://nix.dev/tutorials/module-system/index.html).
This module system is a library that provides a standardized way to merge configurations imported from multiple files.

```nix
{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.vim
  ];

  users.users = {
    drew = {
      home = /Users/drew;
    };
  };
}
```

Using this module system is what allows configuration defined across several files to be merged into a single attribute set that `nix-darwin` can act on.

This module interface defines a function with a standard input and output attribute sets.
In the case of using `nix-darwin`, the output is a snippet of `nix-darwin` configuration.
This doesn't appear to satisfy the expected output of a module as defined in the docs,
and I don't understand why that's acceptable.
A question for another day.

