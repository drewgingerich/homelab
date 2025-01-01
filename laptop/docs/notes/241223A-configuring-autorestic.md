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
  # Home Manager config...

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
# Home Manager config...

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

Turns out that while the launchd agent was correctly created and loaded, it actually wasn't running properly.
I noticed because running `autorestic exec -a -- snapshots` wasn't listing any new snapshots.

Looking at the agent with `launchctl` I can see it has a status of `78` instead of `0` like it should.

```sh
$ launchctl list
PID     Status  Label
-       78      org.nix-community.home.autorestic
```

I have no idea what status `78` means.

I install [LaunchControl](https://www.soma-zone.com/LaunchControl/) through `nix-darwin`'s Homebrew integration,
and it immediately points out that I am trying to execute the directory `/nix/store/dslz0iw4pvi37bjqwx6slb7v00bsvrkf-autorestic-1.8.3` rather
than the executable at `/nix/store/dslz0iw4pvi37bjqwx6slb7v00bsvrkf-autorestic-1.8.3/bin/autorestic`.
I update my Nix config to correct for this:

```nix
# Home Manager config...

launchd = {
  agents = {
    autorestic = {
      enable = true;
      config = {
          Program = "${pkgs.autorestic}/bin/autorestic";
          # Other config...
      };
    };
  };
};
```

That fixed the executable.

Next I saw that it was not running the command I expected, removing `backup` argument.
This caused a failure because `autorestic --all` is not a valid command.

After some digging I learned that the first item of the `ProgramArguments` is the name of the command.
So the string `backup` was being used as the command name instead of the first argument.
To fix this I could prepend another item as the command name:

```nix
# Home Manager config...

launchd = {
  agents = {
    autorestic = {
      enable = true;
      config = {
          Program = "${pkgs.autorestic}/bin/autorestic";
          ProgramArguments = [ "autorestic" "backup" "-av" ];
          # Other config...
      };
    };
  };
};
```

Alternatively, I could not set the `Program` attribute.
In this case, the first element of `ProgramArguments` is used as both the executable program and the command name:

```nix
# Home Manager config...

launchd = {
  agents = {
    autorestic = {
      enable = true;
      config = {
          Program =;
          ProgramArguments = [ "${pkgs.autorestic}/bin/autorestic" "backup" "-av" ];
          # Other config...
      };
    };
  };
};
```

I went with this second option since it seemed a bit simpler.

To test that things were working, I ran to agent manually:

```sh
$ launchctl start org.nix-community.home.autorestic
$ launchctl list | grep autorestic
34308   0       org.nix-community.home.autorestic
$ launchctl list | grep autorestic
-       0       org.nix-community.home.autorestic
```

Seeing it exit with code `0` showed that it was successful.
I also looked at the logs and restic snapshots to double check:

```sh
$ cat ~/Library/Logs/org.nix-community.home.autorestic/stdout.log
# truncated...
snapshot 41b62890 saved
$ autorestic exec -av -- snapshots
# truncated...
41b62890  2025-01-01 01:35:00  laptop-2020              ar:location:data                       /Users/drew/data        8.577 GiB
```

## Other reading

[How Malware Persists on macOS](https://www.sentinelone.com/blog/how-malware-persists-on-macos/)

[^1]: https://github.com/restic/restic/issues/16
[^2]: https://github.com/nix-community/home-manager/issues/5009
[^3]: https://www.launchd.info/
