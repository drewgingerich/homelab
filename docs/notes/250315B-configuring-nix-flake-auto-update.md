# Configuring nix flake automatic updates

I want to keep my system updated,
but I also don't want to need to remember to manually update it.

NixOS provides the [`system.autoUpgrade` option](https://nixos.wiki/wiki/Automatic_system_upgrades) to do this.

https://www.reddit.com/r/NixOS/comments/yultt3/what_has_your_experience_been_with/

This gets complicated when using flakes:
while it can handle flakes and can commit the update,
it doesn't seem like it can push the update.

I also worry that if all of my machines are trying to update automatically and push changes
then I'll frequently need to resolve commit conflicts.

A different way is to update the flake in a centralized manner,
e.g. a scheduled workflow on whatever Git platform.
Since I'm currently using GitHub, a GitHub action is a natural choice.
It also seems like a popular option.

In particular, there is a [pre-made action from Determinate Systems](https://github.com/DeterminateSystems/update-flake-lock).

https://forrestjacobs.com/keeping-nixos-systems-up-to-date-with-github-actions/
