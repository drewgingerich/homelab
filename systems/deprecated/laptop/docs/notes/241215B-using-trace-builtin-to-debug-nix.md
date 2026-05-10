# Using the trace builtin to debug nix

The `builtins.trace` function can be used to print a value to stderr.
I found this helpful when trying to figure out an error,
and also to help understand the shape of an attribute sets passed to me by other people's code.

Unlike, say, `console.log` in JavaScript, `builtins.trace` takes a second argument, which it returns.
This enables it to be used inline, e.g. in the middle of a value assignment.

A good example is inspecting the `osConfig` object passed to my `home-manager` module,
to verify it is indeed the `nix-darwin` configuration.

```nix
{ osConfig, ... }:
{
  home.username = builtins.trace osConfig.users.users.drew "drew";
  home.homeDirectory = /Users/drew;
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
```

```sample
trace: { drew = { createHome = «thunk»; description = «thunk»; gid = «thunk»; home = «thunk»; ignoreShellProgramCheck = «thunk»; isHidden = «thunk»; name = «thunk»; openssh = «thunk»; packages = [ «thunk» ]; shell = «thunk»; uid = «thunk»; }; }
```

I haven't looked into it, but I believe the `«thunk»` values are because Nix is doing lazy evaluation and hasn't evaluated them yet.
If I trace specifically `osConfig.users.users.drew.home` then I get a concrete result `trace: /Users/drew`,
presumably because I've forced Nix to evaluate it.

I do find it a bit weird to trace things unrelated to the code that I'm sticking `builtins.trace` in the middle of,
but I haven't figured out how to use it on its own and it works well enough for me.
