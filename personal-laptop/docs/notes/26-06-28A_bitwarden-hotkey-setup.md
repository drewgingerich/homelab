# Bitwarden hotkey setup

I need to find a way to set up hotkeys for filling out login forms using credentials managed by Bitwarden.

Most of my logins happen in the browser.
For years now I've used Firefox and the Bitwarden extension to automatically populate login forms.
I've recently switched to using [qutebrowser](https://qutebrowser.org/) and absolutely love it,
but qutebrowser doesn't support extensions.

What qutebrowser does support are [userscripts](https://qutebrowser.org/doc/userscripts.html):
executables that qutebrowser calls with a set of environment variables including context like the page URL
and a path to a FIFO queue file for sending commands back to qutebrowser.

Missing out on extensions is slowing me down for the moment,
but I love the whole userscript idea because it gives me a lot of power and control,
and integrates well with the CLI environment that I'm used to.

## Script

So the idea is to create a script using the [Bitwarden CLI](https://bitwarden.com/help/cli/)
to look up logins related to the current page, choose one, and then enter the information.
The qutebrowser repo actually has an [example Bitwarden userscript](https://github.com/qutebrowser/qutebrowser/blob/main/misc/userscripts/qute-bitwarden)!

The Bitwarden CLI is soooo slow!
Like, it takes seconds to query the vault.
Searching around a bit, this seems to be because it decrypts the vault on every invocation.
Good security, I think, but at the cost of too much usability for me,
especially if I do several queries in a script.

[rwb](https://github.com/doy/rbw) is an unofficial Bitwarden CLI that stores the vault in-memory
for a time, make invocations after the initial unlock very fast.
I like it.
I did need to grab my Bitwarden API key to register `rwb`,
otherwise it's API requests returned a 404 since the Bitwarden servers block unknown clients aggressively.

The way the example Bitwarden userscript works is to blindly paste `<username><tab><password>`.
I used to use [KeePassXC](https://keepassxc.org/) which did this too,
and there are unfortunately a lot of websites this macro doesn't work on.
A recent trend I've been seeing is to only show the username field at first,
so I think this situation will get worse.

Instead of this macro, I'd like to be able to paste each bit of information separately.

My first idea was to use some sort of stack-based clipboard manager:
copy all the pieces of info to the clipboard history with a userscript, and then pop them off the stack as I paste each bit of information.
This would give me control over where information gets pasted while providing a streamlined UX.
While this does seem possible with e.g. [clipvault](https://github.com/rolv-apneseth/clipvault),
it feels needlessly complicated to implement and I abandoned this approach.

A simpler alternative is to have a separate hotkeys to paste the username, password, email, TOTP code, and whatever other fields.
This introduces a bunch of hotkeys, but qutebrowser's vim-like hotkey system means
I can put them all behind a "hotkey namespace" e.g. `<leader>bp` to paste the password and `<leader>bu` to paste the username.

## Global hotkeys

This is all well and good for logins in the browser, but what about logins in other applications?
This is an area I've never had a good solution for, relying on manually copying fields from the Bitwarden Desktop application.
Instead of relying on qutebrowser hotkeys, could I make these hotkeys global?

I fell in love with the idea of global Bitwarden hotkeys once I started thinking about them.
It's so simple, it works for everything, and it appears to side-step the security concerns of a Bitwarden browser extension!
But qutebrowser's hotkey system is so nice, can I get something similar at the global level?

## keyd

I am already using [keyd](https://github.com/rvaiya/keyd) for some simple keyboard remaps (I can't live without remapping capslock to escape).
keyd supports hotkey layers, and if you squint, these are the same as hotkey sequences in vim.

I don't just need sequences, though, I need the final key to execute a script.
Lucky for me, keyd supports this with the `command` action[man-keyd].

[man-keyd]: https://raw.githubusercontent.com/rvaiya/keyd/refs/heads/master/docs/keyd.scdoc

In the `keyd.nix` module of my NixOS configuration:

```nix
{ ... }:
{
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "overload(global, esc)";
          };
          global = {
            b = "oneshot(bitwarden)";
          };
          bitwarden = {
            p = "command(bw-paste-password)";
          };
        };
      };
    };
  };
}
```

So `capslock + b` and then `p` should paste a password from Bitwarden.

Now I just need to make a `bw-paste-password` script that lets me select a login and pastes the password.

I take an initial try at this,
using `fuzzel` to display a menu for selecting a login item.
In a `bitwarden.nix` module of my NixOS configuration:

```nix
{ pkgs, ... }:
let
  bwPastePassword = pkgs.writeShellScriptBin "bw-paste-password" ''
    set -euo pipefail

    export PATH=${pkgs.rbw}/bin:${pkgs.dotool}/bin:${pkgs.fuzzel}/bin:${pkgs.wl-clipboard}/bin:$PATH

    item=$(rbw list | fuzzel --dmenu)
    rbw get "$item" | wl-copy --paste-once
    echo key "ctrl+v" | dotool
  '';
in
{
  programs.rbw = {
    enable = true;
    settings = {
      email = "bitwarden@elsewhere.space";
    };
  };

  home.packages = with pkgs; [
    bwPastePassword
  ];
}
```

Note that this script as written won't work on the command line, since pasting there uses `shift+ctrl+v`.
I verify that pasting via `dotool` is working by running it directly with the shift modifier.

```sh
wl-copy Hello, world!
echo key "shift+ctrl+v" | dotool
```
```
Hello, world!
```

Scripts run via `keyd`'s `command` action are run as root.
This causes a few issues:

1. Any user can run the script.
2. The script is not run under my user, so CLI tools run in the script (`rbw`) don't have the proper environment.

My conclusion is that `keyd` is not the right tool for what I want.
The documentation supports this, specifying that the intention behind the `command` action is for system-level scripts such as powering off the computer.

## swhkd

After looking around, I decided to try [swhkd](https://github.com/waycrate/swhkd) for managing hotkeys with a user-level configuration.

`swhkd` is not present in nixpkgs or as a NixOS option, but the repository does have a `flake.nix` file.
There is additionally a helpful issue describing how to set up `swhkd` on NixOS.

https://github.com/waycrate/swhkd/issues/324

The instructions are a bit rough, so I look more closely into how swhkd works.
A privileged daemon, `swhkd` (most easily run as root) listens to keyboard input and executes shell scripts.
A non-privileged daemon, `swhks`, sends the user's environment to the `swhkd` daemon
so it can run scripts on behalf of the user with the right environment.

## What am I doing?

After learning more about the problem space by digging into `keyd` and `swhkd`,
I want to step back and summarize what I believe a solution entails.

1. Capture inputs
2. Parse hotkey combinations
3. Run a script when inputs match a combo
4. Pass through inputs that don't match a combo

### evdev

Inputs can be captured by a program using [evdev][wikipedia-evdev].

[wikipedia-evdev]: https://en.wikipedia.org/wiki/Evdev

https://www.datayard.us/knowledge_articles/linux-keylogging-with-rust-and-evdev/

In order to prevent other programs from capturing the inputs in parallel
and acting before keybinds are matched and executed,
input devices must be grabbed for exclusive use (which is something evdev can do).

https://docs.rs/evdev/latest/evdev/struct.Device.html#method.grab

For inputs that don't match a keybind,
the hotkey program can create a virtual device that re-emit the passed-through inputs.

This is how both `keyd` and `swhkd` work.
Grabbing inputs and creating virtual devices requires elevated permissions,
and this is most easily done by running these services as root.

`keyd` stops here, which is why any script it runs is run as root with the root user environment.
`swhkd` takes an extra step of having a user-level service supply the user environment to the privileged service,
allowing it to run scripts "as a user" (actually still root, but with the user's environment).


An advantage of this setup is that it works independent of whatever else is running on the system.
A downside is the complexity of setting it up.

### Window manager

Window managers are positioned to handle input for all programs a user interacts with,
from the terminal to the browser.
They can monitor for hotkeys, and pass unmatched inputs on to the programs they manage.
And indeed, window managers generally provide some hotkey implementation.

Upside is that the window manager instance is tied to a user session,
so we don't need to deal with all of these privileged service hurdles.

Downside is that we're limited by the hotkey implementation provided.
At time of writing,
Hyprland's keybind system offers [submaps for hotkey sequences][hyprland-keybind-submaps] and configuration as code,
while COSMIC appears to only offer single keybinds and a GUI for configuration.

[hyprland-keybind-submaps]: https://wiki.hypr.land/Configuring/Basics/Binds/#submaps

### Menu program

Even a window manager with a limited keybind implementation may not be a dead-end, though,
because a simple window manager keybind can pass control to something like [fuzzel](https://codeberg.org/dnkl/fuzzel)
configured to handle keybind sequences.

This seams to strike a nice balance, being most independent of the window manager,
but still running under the user without messing with a privileged process.

https://xkbcommon.org/doc/current/xkbcommon-keysyms_8h.html

## Using the Bitwarden CLI

`rbw` is not returning the credit card security code
and the project doesn't appear to get much activity,
so I'm taking another look at using the Bitwarden CLI directly.

The first challenge is to store the session key somewhere so I don't have to unlock the vault on every action.
A keychain program seems like a good fit.

https://grahamwatts.co.uk/gnome-secrets/#how-not-to-do-it

Looking around the web it seems like the GNOME keyring is pretty standard.
Indeed, looking in `/etc/pam.d/login` I see that GNOME keyring is already being used on my system.

https://wiki.archlinux.org/title/GNOME/Keyring

I also found the [freedesktop Secret Service spec](https://specifications.freedesktop.org/secret-service/latest/index.html),
which is an open standard and interface for keyrings on Linux.

One interesting outcome of this Secret Service stuff is that there is a CLI tool, `secret-tool` for interacting with any keyring,
so long as it implements the spec
My understanding is that GNOME keyring implements the Secret Service spec.

It took me a bit to understand how to use `secret-tool`.

```sh
# Store a secret
echo "Super secret" | secret-tool store --label=Foobar foo bar

# Fetch a secret
secret-tool lookup foo bar

# Delete a secret
secret-tool clear foo bar
```

The thing that took getting used to is that working with secrets is entirely attribute-based.
It's not possible to look up an item by label or ID, only by attribute.

Items can be tagged with multiple attributes,
and multiple attributes can be used to look up an item.

```sh
echo "Super secret" | secret-tool store --label=Foobar foo bar baz qux
echo "Super secret 2" | secret-tool store --label=Foobar foo bar baz wux

# Will return one of the two
# Looks like it returns the most recently changed
# Not something I want to rely on
secret-tool lookup foo bar

# Remove ambiguity by specifying more attributes so there's only one match
secret-tool lookup foo bar baz qux
```

There doesn't appear to be a way to list all items.
I did find something that works well enough, though,
which is to look up using the attribute `xdg:schema org.freedesktop.Secret.Generic`.
My understanding is that this attribute is automatically added to every item.
There may be a different automatic attribute in other setups.

https://discourse.gnome.org/t/how-do-you-actually-use-secret-tool/19818

```sh
# Pipe to `less` because the response includes the secret values
 secret-tool search --all xdg:schema org.freedesktop.Secret.Generic | less
 ```

...and time passes...

Using the `bw` CLI was still slow.
I have an idea of using the keychain to cache the selected item,
and maybe that'd work, but for now I'm still using `rbw`.
I am storing the item ids in the keychain instead of in files in my home directory now,
which I think is a small aesthetic improvement.

## Loose ends

Why does `rbw` use `pinentry`?

https://velvetcache.org/2023/03/26/a-peek-inside-pinentry/

https://github.com/waycrate/swhkd/issues/319

## Other things found along the way

https://mark.stosberg.com/universal-copy-paste/

http://who-t.blogspot.com/2018/07/why-its-not-good-idea-to-handle-evdev.html

https://gist.github.com/TriceHelix/de47ed38dcb4f7216b26291c47445d99

https://wayland.freedesktop.org/libinput/doc/latest/architecture.html
