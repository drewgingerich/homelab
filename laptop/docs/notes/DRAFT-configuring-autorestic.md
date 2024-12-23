# Configuring autorestic

I like to use [restic](https://restic.net/) for backups.

While I like restic's features, running it involves a long command with a lot of flags for
specifying the remote repo and paths to back up.
I can never remember the whole thing.
There is an open issue to add a configuration file to make this a smoother experience[^1].

I use the third-party tool [autorestic](https://github.com/restic/restic/issues/16) to manage restic via a
configuration file, and this has worked well for me for years.

An alternative could be a `nix` module for managing restic.
While there is a module for `nixOS`, there is not for `nix-darwin` or Home Manager.
There is an open Home Manager issue for implementing a restic module[^2].
For now I'll keep using autorestic.

Since I only want to back up my `$HOME/data` directory,
which just has data that is personal to me,
I will configure autorestic using Home Manager.

I installed restic and autorestic:

```nix
  home.packages = with pkgs; [
    restic
    autorestic
  ];
```

I created an autorestic config at `dotfiles/autorestic/.autorestic.yml` to back up `~/data`:

```yaml
version: 2
backends:
  backblaze:
    type: b2
    path: gjiWYUXh9Y
locations:
  data:
    from:
    - /wish/app-data
    - /wish/media/pictures
    - /wish/media/home-video
    to:
    - backblaze
    cron: '0 2 * * *'
    options:
      all:
        host: kyubey
      forget:
        keep-daily: 7
        keep-weekly: 4
        keep-monthly: 6
```

Note that I am supplying sensitive data using an [env file](https://autorestic.vercel.app/backend/env#env-file),
to keep it out of version control.

I linked the config to `~/.config/autorestic`:

```nix
  # Home Manager config ...

  xdg.configFile = {
    "autorestic" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/data/code/homelab/dotfiles/autorestic";
    };
  };
```

I run some commands to see if things are working:

```sh
$ autorestic check
```


[^1]: https://github.com/restic/restic/issues/16
[^2]: https://github.com/nix-community/home-manager/issues/5009
```

