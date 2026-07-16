# Use dendritic NixOS configuration pattern

## Problem

I need a pattern that allows me to:

- share configuration across multiple computers
- handle variations in configuration between systems
- co-locate configuration that contributes to the same feature or aspect

## Decision

Use the dendritic NixOS configuration pattern:

- Define all configuration as NixOS modules
- Use `flake-parts` to expand the module system to include flake outputs.

## Exploration

The NixOS module system already solves these problems:

- configuration sharing: module `imports`
- configuration variation: module `options`
- configuration co-location by aspect: configuration merging allows it to be defined in fragments across multiple files

By writing configuration as NixOS modules,
custom configuration can tap into these solutions.

Projects like NixOS, nix-darwin, and Home Manager provide their own collections of modules.
These module collections are generally not compatible with each other,
e.g. a configuration cannot target multiple of these tools at once.

This is a problem because I find that some aspects of configuration encompass more than one of these tools.
Nix garbage collection can be configured for both NixOS and nix-darwin, for example,
but NixOS uses `nix.gc.dates` while nix-darwin uses `nix.gc.interval`.

The easiest solution is to split each aspect of configuration into a separate piece for each tool.

```
fish/home-manager.nix
```

```nix
home.packages = [ pkgs.fish ];

xdg.configFile = {
  "fish" = { source = "./dotfiles"; };
};
```

```
fish/nixos.nix
```

```nix
programs.fish.enable = true;
home-manager.sharedModules = [ ./home-manager.nix ];
```

This breaks my desire to co-locate all configuration related to an aspect, though.
I'd like to keep all configuration related to Nix garbage collection in one file,
for example, and I'd like to keep all configuration related to `fish` in another.

Flakes solve this problem by defining a separate output attribute for each of these tools,
allowing a single configuration to be consumed by multiple Nix tools.

The module system is only run within each tool's configuration and don't extend up to the level of the flake, though,
so we can't leverage the module system to handle sharing and variation in flake outputs.

This problem is solved by the [`flake-parts` library][flake-parts-site],
which provides modules to for flake outputs.

[flake-parts-site]: https://flake.parts/

```
fish.nix
```
```nix
{
    home-manager = {
        home.packages = [ pkgs.fish ];

        xdg.configFile = {
          "fish" = { source = "./dotfiles"; };
        };
    };

    nixos = {
        programs.fish.enable = true;
        home-manager.sharedModules = [ ./home-manager.nix ];
    };
};
```

## Side effects

## Further reading

https://github.com/mightyiam/dendritic
https://not-a-number.io/2025/refactoring-my-infrastructure-as-code-configurations/
https://github.com/Doc-Steve/dendritic-design-with-flake-parts/blob/main/README.md
https://discourse.nixos.org/t/one-module-that-combines-home-manager-and-system-packages/37951/7
