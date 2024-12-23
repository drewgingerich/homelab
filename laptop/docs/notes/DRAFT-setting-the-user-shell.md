# `nix-darwin`: setting the user shell

I currently like using the [fish shell](https://fishshell.com/),
but zsh is the default on macOS.

I can change my default shell manually using:

```sh
sudo chsh -s drew <path-to-fish>
```

It seems like `nix-darwin` removes the file `/etc/shells`.
How am I able to set my shell without this file?

I can get `nix-darwin` to generate `/etc/shells` by adding a shell to
the `environment.shells` option:

```nix
environment.shells = [
  pkgs.fish
];
```

Should I do this?

`nix-darwin` can set a default shell for a user by enabling the shell and 
setting the `uses.users.<name>.shell` option:

```nix 
programs.fish.enable = true;
users.users = {
  drew = {
    shell = pkgs.fish;
  };
};
```

Why is `programs.fish.enable` necessary?

For `nix-darwin` to actually act on this, the user must be added to
the `users.knownUsers` option:

```nix
users.knownUsers = [ "drew" ]
```

HOWEVER, the documentation suggests not to do this for the main user.
What's the risk?


An alternative to using `users.users.<name>.shell` could be to use an
activation script to set the shell whenever running `nix-darwin`:

```nix
programs.fish.enable = true;
system.activationScripts.setFishAsShell.text = ''
  dscl . -create /Users/${user} UserShell ${pkgs.fish}
'';
```

[^1]: https://github.com/LnL7/nix-darwin/blob/master/modules/users/default.nix#L61
[^2]: https://github.com/LnL7/nix-darwin/issues/811
[^3]: https://github.com/LnL7/nix-darwin/issues/328
[^4]: https://github.com/LnL7/nix-darwin/pull/1120/
