# Setting up dotfiles with Home Manager

I want to use Home Manager to declaratively manage my dotfiles.

## Option 1: Home Manager modules

Some of the tools I use have dedicated Home Manager modules,
such as [the module for starship](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.starship.enable).

```nix
  programs.starship.enable
```

Since I already have a collection of dotfiles, I don't want to go this direction right now.
I can see the potential of managing interrelated configuration this way,
such as adding `direnv` initialization to my shell configuration when the direnv module is enabled.
I will probably explore this in the future.

## Option 2: `home.file` option with an in-store symlink

Home Manager provides the [`home.file` option](https://nix-community.github.io/home-manager/options.xhtml#opt-home.file) to copy files from the store into the target location.

For example, to copy the [Starship](https://starship.rs/) config:

```nix
  # Home Manager config...

  home.file = {
    ".config/starship.toml" = {
      source = ../dotfiles/starship/starship.toml;
    };
  };
```

I can use a relative path, from the perspective of the Nix file in which this is configured.

A reminder that the config file must be tracked in Git for it to be picked up, since I'm using a flake.

## Option 3: `home.file` option with an out-of-store symlink

A downside of linking to files in the Nix store is that updates to the file will only be available after re-running `darwin-rebuild switch`.

It is possible to set up a link to a file outside of the store using the `config.lib.file.mkOutOfStoreSymlik` function.

```nix
  home.file = {
    ".config/starship.toml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix-darwin/dotfiles/starship/starship.toml";
    };
  };

  # And other Home Manager config...
```

This requires an absolute path to reference the file when using a Nix flake.
This can be made more portable by interpolating `config.home.homeDirectory`.

The end result is three links: config -> store -> store -> source.

The store to store link is an implementation detail I don't understand,
but conceptually all that's happening is a symlink is put into the store,
and this symlink points at whatever target was configured.

The symlink pointing to the config is handled by Nix,
but the config it's pointing too is no longer managed by Nix.
This means the Nix config is impure: part of the setup no longer has Nix's guarantees of isolation and reproducibility.
It's up to me to make sure the configuration is actually there.

In practice this doesn't feel like a big deal right now since I'll be keeping the config source in
the same repo as the nix-darwin config.
I also appreciate the convenience of not having to run the nix-darwin rebuild as much,
since I'm iterating pretty fast right now and the waiting adds up fast.

## Option 4: `xdg.configFile` option

The [`xdg.configFile` option](https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.configFile)
appears to be syntactic sugar for `home.file` with the value of the [`xdg.configHome`](https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.configHome)
prepended to the path.

```nix
  xdg.configFile = {
    "starship.toml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix-darwin/dotfiles/starship/starship.toml";
    };
  };
```

This fits my use case, so it looks more convenient than `home.file`.

## Further reading

https://codeberg.org/justgivemeaname/.dotfiles
https://seroperson.me/2024/01/16/managing-dotfiles-with-nix/
https://discourse.nixos.org/t/how-to-manage-dotfiles-with-home-manager/30576
https://github.com/nix-community/home-manager/issues/2085
https://github.com/nix-community/home-manager/issues/3514
