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
  users.users.drewg = {
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
  users.users.drewg = {
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
{ config, pkgs, ... }:
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

If I imported as a system-level module instead then it works.
I have to specify the username, however, which kills the reusability.


```nix
# configuration.nix
{ pkgs, ... }:
{
  users.users.drewg = {
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
username:
{ config, pkgs, ... }:
{
  programs.fish.enable = true;
  users.users.${username} = {
    shell = pkgs.fish;
  };

  home-manager.users.${username} = {
    home.packages =  [ pkgs.fish ];
    xdg.configFile = {
      "fish" = { source = "../dotfiles/fish"; };
    };
  };
}
```

One option is to turn the NixOS module into a function,
taking in a username and outputting config targeting that user.

https://discourse.nixos.org/t/multiple-users-with-home-manager-as-nixos-modules/49672/3

```nix
username:
{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  home-manager.users.$username = {
    systemd.user.services.steam = {
      enable = true;
      description = "Open Steam Big Picture Mode at boot";
      serviceConfig = {
        ExecStart = "${pkgs.steam} -bigpicture";
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
```




https://www.reddit.com/r/NixOS/comments/1dtgavp/combining_global_and_homemanager_options_in_a/
https://github.com/mcdonc/.nixconfig/blob/master/videos/peruserperhost2/script.rst
https://codeberg.org/Gipphe/dotfiles
