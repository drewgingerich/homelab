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
      - ~/data
    to:
      - backblaze
    cron: "0 2 * * *"
    options:
      all:
        host: my-host
      forget:
        keep-daily: 7
        keep-weekly: 4
        keep-monthly: 6
```

Note that I am supplying sensitive data using a [.autorestic.env file](https://autorestic.vercel.app/backend/env#env-file),
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

I run `autorestic check` to verify this config is working:

```sh
$ autorestic check
Using config:    /Users/drew/.config/autorestic/.autorestic.yml
Using env:       /Users/drew/.config/autorestic/.autorestic.env
Using lock:      /Users/drew/.config/autorestic/.autorestic.lock.yml
Everything is fine.
```

At this point I can manually run the backup job.
This is great, but I'd also love to automatically run the backup job once a day.
[Launchd](https://en.wikipedia.org/wiki/Launchd) is the way to do this on macOS[^3],
and Home Manager has a [launchd module](https://github.com/nix-community/home-manager/blob/master/modules/launchd/default.nix).

```nix
# Home Manager config ...

launchd = {
  agents = {
    autorestic = {
      enable = true;
      config = {
          Program = "${pkgs.autorestic}";
          ProgramArguments = [ "backup" "-av" ];
          StartCalendarInterval = [{
            Hour = 5;
            Minute = 0;
          }];
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/org.nix-community.home.autorestic/stderr.log";
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/org.nix-community.home.autorestic/stdout.log";
      };
    };
  };
};
```

After a rebuild, I can see that it worked by checking for the agent plist file and by `launchctl`:

```sh
$ ls ~/Library/LaunchAgents/
com.valvesoftware.steamclean.plist  org.nix-community.home.autorestic.plist
$ launchctl list | grep autorestic
-       0       org.nix-community.home.autorestic
```

A potential issue is that log files can grow indefinitely.
I don't think this will be an issue, as running autorestic once per day shouldn't generate much log volume.
If necessary, I can set up something like `newsyslog` to rotate and prune the log files.

## Other reading

[How Malware Persists on macOS](https://www.sentinelone.com/blog/how-malware-persists-on-macos/)

[^1]: https://github.com/restic/restic/issues/16
[^2]: https://github.com/nix-community/home-manager/issues/5009
[^3]: https://www.launchd.info/
