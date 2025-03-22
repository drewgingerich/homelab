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
While I could split it up into more modules, there's a core problem that
sometimes system state and user state need to be configured together.
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

```nix
# configuration.nix
{ pkgs, ... }:
{
  # NixOS config
  programs.fish.enable = true;
  users.users.drew = {
    home = "/home/drew";
    shell = pkgs.fish;
  };

  # Home Manger config
  home-manager.users.drew = {
    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
    home.packages = [ pkgs.fish ];
    xdg.configFile = {
      "fish" = { source = "../dotfiles/fish"; };
    };
  };
}
```

To go a bit farther, what the `nixpkgs.lib.nixosSystem` function does is not too complicated.
First it brings in packages needed to set up a basic functioning operating system.
Then it passes the list of modules provided by the user
to the [`lib.evalModules` function](https://github.com/NixOS/nixpkgs/blob/master/lib/modules.nix#L87)
to do all the custom configuration.

https://www.reddit.com/r/NixOS/comments/13oat7j/what_does_the_function_nixpkgslibnixossystem_do/

That's a start, but I'd really like to move out cross-cutting user + system config into modules.
For example extracting out everything related to the fish shell.

```nix
# configuration.nix
{ pkgs, ... }:
{
  users.users.drew = {
    home = "/home/drew";
  };

  home-manager.users.drew = {
    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
    imports = [ ../modules/fish.nix ];
  };
}
```
```nix
# modules/fish.nix
{ pkgs, ... }:
{
  programs.fish.enable = true;
  users.users.drew = {
    shell = pkgs.fish;
  };
  home.packages =  [ pkgs.fish ];
  xdg.configFile = {
    "fish" = { source = "../dotfiles/fish"; };
  };
}
```

This doesn't work because modules imported with `home-manager.users.<user>.imports`
are merged into the `home-manager.users.<user>` attribute set.
Setting `programs.fish.enable` in the module above actually tries
to set `home-manager.users.drew.programs.fish.enable`, which doesn't exist.
In other words, they are not able to set system-level configuration.

If I import the module as a system-level module instead then it works.

```nix
# configuration.nix
{ pkgs, ... }:
{
  users.users.drew = {
    home = "/home/drew";
  };

  home-manager.users.drew = {
    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
  };

  imports = [ ../modules/fish.nix ];
}
```
```nix
# modules/fish.nix
{ pkgs, ... }:
{
  programs.fish.enable = true;

  users.users.drew = {
    shell = pkgs.fish;
  };

  home-manager.users.drew = {
    home.packages =  [ pkgs.fish ];
    xdg.configFile = {
      "fish" = { source = ../dotfiles/fish; };
    };
  };
}
```

The username is hardcoded, however, which kills the reusability.
Ideally I want to import this type of module for multiple users.

One solution is to turn the module into a function,
taking in a username and returning a module with the username set.

https://discourse.nixos.org/t/multiple-users-with-home-manager-as-nixos-modules/49672/3

```nix
# configuration.nix
{ pkgs, ... }:
{
  users.users.drew = {
    home = "/home/drew";
  };

  home-manager.users.drew = {
    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
  };

  imports = [
    (import ../modules/fish.nix "drew") # Parentheses are necessary
  ];
}
```
```nix
# modules/fish.nix
username:
{ pkgs, ... }:
{
  programs.fish.enable = true;
  users.users.${username} = {
    shell = pkgs.fish;
  };

  home-manager.users.${username} = {
    home.packages =  [ pkgs.fish ];
    xdg.configFile = {
      "fish" = { source = ../dotfiles/fish; };
    };
  };
}
```

This works!
It's a little weird looking, mixing NixOS module imports with the Nix language `import` keyword.

Another option is to use Home Manager's `sharedModules` option,
which automatically adds a module for each user.

https://www.reddit.com/r/NixOS/comments/1dtgavp/combining_global_and_homemanager_options_in_a/

```nix
# configuration.nix
{ pkgs, ... }:
{
  users.users.drew = {
    home = "/home/drew";
  };

  imports = [
    ../modules/fish.nix
  ];

  home-manager.users.drew = {
    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
    custom-home.fish.enable = true;
  };
}
```
```nix
# modules/fish.nix
{ config, pkgs, ... }:
{
  programs.fish.enable = true;

  home-manager.sharedModules = [(
    { config, pkgs, lib, ... }:
    {
      options.custom-home.fish.enable = lib.mkEnableOption "Enable fish shell for this user";

      config = lib.mkIf config.custom-home.fish.enable {
        home.packages =  [ pkgs.fish ];
        xdg.configFile = {
          "fish" = { source = ../dotfiles/fish; };
        };
      };
    }
  )];
}
```

Being able to put just `fish.enabled = true` in my user config is pretty slick,
compared to the somewhat tortured function import above.

I like this architecture because I think of it as the system declaring what user capabilities
are available, which can then be enabled or disabled on a per-user basis.

It doesn't let me modularize user-specific configuration that is not part of Home Manager,
a.k.a. anything under `users.users.<name>`.
Most `users.users` configuration doesn't need to coordinate with Home Manager configuration,
but `users.users.<user>.shell` is an exception I'm running into.

Changing my mental model a bit, I think this is fine:
shell config and the default shell are not necessarily one-to-one.
I may configure multiple shells, and independently change the default shell from time to time.
This means using `sharedModules` meets my needs well.

The `sharedModules` option is only available when Home Manager is
running as a NixOS or nix-darwin module, not standalone.
Since I want to run Home Manager standalone on my work laptop,
I need to figure out a way to do both.

I can extract the Home Manager config into it's own home-level module,
and import that into the system-level module that exposes it as using `sharedModules`.
NixOS and darwin-nix systems can use the system-level module,
while standalone Home Manager installs can use the home module directly.

```nix
# hm/drew.nix (Home Manager standalone)
{ pkgs, ... }:
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  home.packages = with pkgs; [
    direnv
    htop
  ];

  imports = [
    ../modules/home/fish.nix
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "24.05";
}
```nix
# nixos/configuration.nix (NixOS)
{ ... }:
{
  users.users.drew = {
    home = "/home/drew";
  };

  imports = [
    ../modules/system/fish.nix
  ];

  home-manager.users.drew = {
    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
    custom-home.fish.enable = true;
  };
}
```
```nix
# modules/system/fish.nix
{ config, lib, ... }:
{
  programs.fish.enable = true;

  home-manager.sharedModules = [{
    options.custom-home.fish.enable = lib.mkEnableOption "Enable fish shell for this user";
    config = lib.mkIf config.custom-home.fish.enable {
      imports = [ ../../home/fish.nix];
    };
  }];
}
```
```nix
# modules/home/fish.nix
{ pkgs, ... }:
{
  home.packages =  [ pkgs.fish ];
  xdg.configFile = {
    "fish" = { source = ../../dotfiles/fish; };
  };
})
```

This 

https://www.reddit.com/r/NixOS/comments/10c3s93/homemanager_nixos_module_or_best_practice_for/
https://github.com/mcdonc/.nixconfig/blob/master/videos/peruserperhost2/script.rst
https://codeberg.org/Gipphe/dotfiles
