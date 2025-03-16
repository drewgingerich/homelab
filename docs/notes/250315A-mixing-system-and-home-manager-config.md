# Mixing system and Home Manager config

Currently my flake outputs look something like this:

```nix
  outputs = {
    nix-darwin,
    home-manager,
    nixpkgs,
    ...
  }: {
    darwinConfigurations.unremarkable-macbook-pro = nix-darwin.lib.darwinSystem {
      system = " x86_64-darwin";
      modules = [
        ./laptop/nix/configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = ".hm.bak";
          home-manager.users.drew = import ./home.nix;
        }
      ];
    };
```

Keeping all Home Manager configuration in `home.nix` is not ideal.
I could split it up into a bunch of modules, but there's a core problem that
sometimes systems state and user state need to be configured together.
I want to understand how to do this.

My first learning is that the attribute set setting `home-manager` options above is not
an argument to a `home-manager.darwinModules.home-manager` function, like I had assumed.
Instead, `home-manager.darwinmodules.home-manager` is a [nix module](https://nixos.wiki/wiki/NixOS_modules).
Note that for NixOS systems the module to use is `nixpkgs.lib.nixosSystem` instead.

A module is not a nix language construct, but rather a pattern built for the NixOS ecosystem. 
The module system takes care of merging configuration from different modules,
and providing validate-able interfaces for configuring each module called `options`.

The `nix-darwin.lib.darwinSystem` function takes in an attribute set, and inside this the `modules` attribute
is a list of modules to evaluate. NixOS systems use the `nixpkgs.lib.nixosSystem` function instead.

Modules can bring in other modules using the `imports` attribute, which is an array of module file paths.

To get back to `home-manager.darwinModules.home-manager`, this is a module that exposes the Home Manager options.
Once the options are in scope, they can be used from any other module.

Tl;dr: what I thought was a problem was just a poor assumption,
and I'm already able to mix NixOS and Home Manager configuration.

To go a bit farther, what the `nixpkgs.lib.nixosSystem` function does is not too complicated.
First it brings in packages needed to set up a basic functioning operating system.
Then it passes the list of modules provided by the user
to the [`lib.evalModules` function](https://github.com/NixOS/nixpkgs/blob/master/lib/modules.nix#L87)
to do all the custom configuration.

https://www.reddit.com/r/NixOS/comments/13oat7j/what_does_the_function_nixpkgslibnixossystem_do/

https://www.reddit.com/r/NixOS/comments/1dtgavp/combining_global_and_homemanager_options_in_a/
https://github.com/mcdonc/.nixconfig/blob/master/videos/peruserperhost2/script.rst
https://codeberg.org/Gipphe/dotfiles
