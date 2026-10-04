I'm curious about NixOS containers.

I currently run services in Docker containers,
which provide a few qualities I appreciate:

- Private network: avoids port conflicts, e.g. between multiple postgreSQL instances.
- Impermenant filesystem: prevents buildup of filesystem cruft. Avoids dependency conflicts.
- Reproducible installation: I can pin the container image to run the same
  version of the software

Nix provides reproducible installation and avoids dependency conflicts.
It also minimizes filesystem cruft to some degree,
since system directories are re-created on each switch.

That leaves me with needing private networks and a complete way to prevent filesystem cruft.
NixOS containers look like they can provide these features, 
with the benefit of being configured as a NixOS module.

https://wiki.nixos.org/wiki/NixOS_Containers

NixOS containers are a wrapper around systemd-nspawn.

https://wiki.archlinux.org/title/Systemd-nspawn

https://quantum5.ca/2025/03/22/whirlwind-tour-of-systemd-nspawn-containers/

https://www.freedesktop.org/software/systemd/man/latest/systemd-nspawn.html

Setting `containers.<name>.privateNetwork = true` gives the container it's own private network stack,
which handles my need for a private network per service.

https://search.nixos.org/options?channel=26.05&query=containers&type=options#show=option%253Acontainers.%253Cname%253E.privateNetwork

Setting `containers.<name>.ephemeral = true` makes the filesystem of the container completely ephemeral,
preventing filesystem cruft.

https://search.nixos.org/options?channel=26.05&query=containers&type=options#show=option%253Acontainers.%253Cname%253E.ephemeral

Persistent data can be handled using bind mounts.


```nix
{ config, ... }:
{
  containers.someContainer = {
    bindMounts = {
      someMount = {
        hostPath = "/tmp/host_dir"; 
        mountPoint = "/tmp/container_dir";
        isReadOnly = false;
      };
    };
  };
};
```

With this, anything written to `/tmp/container_dir` within the container will be persisted under `/tmp/host_dir` on the host.

By default there's no user namespacing, so UIDs and GIDs within the container are from the same pool as those on the host.
This can be convenient when only using containers for other features, e.g. network namespacing,
since files owned by a user in the container can be owned by an analagous host user.

The host user and container user UIDs must match, though, and from what I can see, this correlation must be handled manually.
I've tried creating a host user and reusing that configuration within the container,
but I got an infinite recursion error and stopped.

https://www.reddit.com/r/systemd/comments/p4vikd/can_a_user_from_inside_a_nspawn_container_own_a/

systemd-nspawn provides another solution, which is the `owneridmap` bind mount mode.
My understanding is that this mode maps the host UID of the source dir to the container UID of the target dir.
This should work even with user namespacing enabled.

https://man.archlinux.org/man/systemd-nspawn.1#Mount_Options

The NixOS containers modules doesn't currently specify an option to set the mode,
but there is a workaround by including the mode in the mountPoint string.

https://github.com/NixOS/nixpkgs/issues/329530

```nix
{ config, ... }:
{
  containers.someContainer = {
    bindMounts = {
      someMount = {
        hostPath = "/tmp/host_dir"; 
        mountPoint = "/tmp/container_dir:owneridmap";
        isReadOnly = false;
      };
    };
  };
};
```

Despite the docs, this appears to make the mounted directory owned by root. Bah!

https://github.com/systemd/systemd/issues/38771

I opened up a topic on NixOS Discourse, but haven't heard back.
I'm pausing this exploration for now.

https://discourse.nixos.org/t/nixos-container-bind-mount-ownership-trouble-with-owneridmap/80327
