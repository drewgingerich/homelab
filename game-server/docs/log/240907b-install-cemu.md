Installing [Cemu](https://cemu.info/) was as fast as adding it as a system package:

```nix
environment.systemPackages = with pkgs; [
  cemu
]
```

I created a few directories under the `steam` user home folder for Cemu data:

```sh
$ mkdir -p /home/steam/cemu/games /home/steam/cemu/mlc
```

After starting Cemu, I configured it to use these folders.
I also configured the input settings and other settings to my preferences.

I'm not sure if it would be possible to capture this configuration in Nix Home Manager.
Could be a nice future project.
