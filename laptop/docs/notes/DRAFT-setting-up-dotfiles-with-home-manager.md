# Setting up dotfiles with Home Manager

I want to use Home Manager to declaratively manage my dotfiles.

## Option 1: Home Manager modules

Some of the tools I use have dedicated Home Manager modules,
such as [the module for direnv](https://github.com/LnL7/nix-darwin/blob/master/modules/programs/direnv.nix).

Since I already have a collection of dotfiles, I don't want to go this direction right now.
I can see the potential of managing interrelated config this way,
such as adding direnv initialization to my shell config when the direnv module is enabled.
I will probably explore this in the future.

## Option 2: `home.file` option

https://seroperson.me/2024/01/16/managing-dotfiles-with-nix/
https://discourse.nixos.org/t/how-to-manage-dotfiles-with-home-manager/30576
https://github.com/nix-community/home-manager/issues/2085
https://github.com/nix-community/home-manager/issues/3514

Home Manager provides the [`home.file` option](https://nix-community.github.io/home-manager/options.xhtml#opt-home.file) to copy files from the store into the target location.

For example, to copy the [Starship](https://starship.rs/) config:

```nix
  home.file = {
    ".config/starship.toml" = {
      source = "${config.home.homeDirectory}/.config/starship.toml";
    };
  };

  # And other Home Manager config...
```

## Option 2: `xdg.configFile` option

`https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.configFile`

## Create symlink to config file

## Further reading

https://codeberg.org/justgivemeaname/.dotfiles
