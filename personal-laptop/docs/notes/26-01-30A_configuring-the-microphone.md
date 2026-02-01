# Configuring the microphone

Out of the box, the builtin microphone doesn't work.

I'm using Cosmic DE.

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

At some point the input option changed to `Digital Microphone - Ryzen HD Audio`,
no idea why.

The microphone has a lot of noise.
Much of it seems to be because 100% volume is way too high.

I used `alsamixer` to change the microphone volume to 30.

```sh
alsamixer
```

https://askubuntu.com/questions/27021/setting-microphone-input-volume-using-the-command-line/27032#27032

The Cosmic DE sound settings don't show the same volume as `alsamixer`.
My guess is that it's a bug with Cosmic's sound settings page.

`pactl list` and `aplay -l` also appear to be useful commands, but I don't need them here.

https://community.frame.work/t/microphone-extremely-staticy/15533/12

The microphone is working and has a reasonable gain,
but I'm still getting noise.

I install EasyEffects and add a few filters:

1. Noise Reduction
2. Echo Canceller
3. Compressor
4. Limiter

https://github.com/wwmm/easyeffects/discussions/1227

Exact settings are stored in my Nix configuration.

Now the microphone is sounding pretty good, even in programs that don't provide their own noise control.
Plus I can add fun effects like pitch shifting!

[^1]: ttps://community.frame.work/t/laptop13-ryzen-ai-340-internal-mic-in-fedora42-doesnt-work/75748/8

