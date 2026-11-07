---
tags:
  - "scope:personal-laptop"
---

# Accessing homeModule flake output from imported nixosModule

## Shared modules

Expose Home Manager modules using the `sharedModules` option.

```nix
{ inputs, ... }:
{
  flake.homeModules.fish =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options.custom.fish.enable = lib.mkEnableOption "Fish shell";

      config = lib.mkIf config.custom.fish.enable {
        home.packages = [ pkgs.fish ];

        xdg.configFile = {
          "fish" = {
            source = ../dotfiles/fish;
            recursive = true;
          };
        };
      };
    };

  flake.nixosModules.fish =
    { ... }:
    {
      programs.fish.enable = true;
      home-manager.sharedModules = [ inputs.self.homeModules.fish ];
    };

  flake.darwinModules.fish =
    { ... }:
    {
      programs.fish.enable = true;
      home-manager.sharedModules = [ inputs.self.homeModules.fish ];
    };
}
```

---

My user configuration is the last in a number of layers:

1. Flake outputs are merged using `flake-parts.lib.mkFlake`.
2. Machine configuration is imported by relative path in the `imports` attr.
3. Machine configuration is defined using `nixpkgs.lib.nixosSystem`.
4. Bespoke configuration is imported by relative path in the `modules` attr.
5. User configuration is imported by relative path in the module `imports` attr.

My user configuration needs access to packages and Home Manager modules exposed as an output of my flake.
The flake outputs are accessible from the `self` attribute,
but `self` is not available in my user configuration.

One solution is to promote my user configuration to be a flake-parts module,
which gets passed `self` as a module argument.

I find I'm resistent to this setup because my users are bespoke to the systems they're on,
and exposing them in the flake outputs independent from their system communicates the opposite.
I've already pulled shared configuration out into Home Manager modules.

This resistance is silly, though!
I already declare configurations for specific machines as nixosConfigurations.
Just make homeConfigurations outputs for users already!

Okay, but it's still frustrating because it feels like there should be some heirarchy,
with homeConfigurations under nixosConfigurations.
A nixosConfiguration will work alone, while some homeConfigurations won't.

What's an example? I'm not sure if this is true.
If there is a case where it's true, we can mitigate the risk using assertions
that check the `osConfig` in the Home Manager module.

I still want to figure out how to access the flake outputs from the user configuration module.

The problem is that there are two scopes at play here: the flake and the nixos configuration.
The flake layer merges flake modules to produce a flake output attrs.
The nixos configuration layer merges nixos modules to produce a nixos configuration.

Flake modules are provided with the `inputs` argument, which contains `self`.

NixOS modules are not provided with `inputs`.
NixOS modules don't have any notion of a flake: building a NixOS system simply takes a NixOS module,
whether it's defined as a flake output or by itself in a `configuration.nix` file.
NixOS modules have no awareness that they are running in a flake,
and now awareness of `self` since it's a (automatic) flake input.

When using flake-parts, NixOS modules are often defined within flake modules.
Attributes available in the flake module can be passed to a NixOS module defined within.
A second nixos module defined in a file imported by the nixos module
is not being defined within the flake module scope,
so flake module attributes can't be references directly.
This is just an example of the convenience of function closures.

One solution is to write every NixOS module inside a flake module.
This makes it so that the `self` provided to the flake module can be used in each NixOS module.

Another solution is to use the `specialArgs` attribute of the attrs passed to `nixosSystem`.

There's also `_module.args`, which does a similar thing.
I'll have to look more into how they're different.

https://github.com/NixOS/nixpkgs/blob/695027f61c702ea0de6baa3122b282d672fede09/lib/modules.nix#L43
