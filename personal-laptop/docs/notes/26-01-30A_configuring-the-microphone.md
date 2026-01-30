# Configuring the microphone

Out of the box, the builtin microphone doesn't work.

I'm using COSMIC DE.

To get it to work I go to the Sound settings > Device profiles
and change it from `Play HiFi quality Music (Headset, Mic2, Speaker)` to `Play HiFi quality Music (Mic1, Mic2, Speaker)`.
I then change the input device to `Internal Stereo Microphone - Family 17h/19h/1ah HD Audio`.

For some reason, the settings always revert back to `Digital Microphone - Family 17h/19h/1ah HD Audio`,
but I get microphone input either way.

It sounds awful, with lots of crackly noise.
Turns out that input volume 100% is way too high.
Setting it to 30% results in a clear voice with little noise.

New problem: the volume settings reverts to 100% when I leave the sound settings.
Looking around, I see the suggestion to blacklist the `snd_soc_dmic` kernal module.[^1]

I add this to my NixOS configuration, switch, and reboot.

```nix
  boot.extraModprobeConfig = ''
    blacklist snd_soc_dmic
  '';
```

After this, the only input option is `Internal Microphone - Family 17h/19h/1ah HD Audio`
and the volume stays where I put it.

[^1]: ttps://community.frame.work/t/laptop13-ryzen-ai-340-internal-mic-in-fedora42-doesnt-work/75748/8
