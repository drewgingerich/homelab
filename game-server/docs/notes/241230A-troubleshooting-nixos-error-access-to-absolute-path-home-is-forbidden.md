# Troubleshooting NixOS error: `access to absolute path '/home' is forbidden`

While trying to integrate Home Manager into my NixOS config,
I updated the home directory option from a hardcoded string to a string interpolation:

```nix
users.users = {
  ${username} = {
    home = /home/${username};
  }
}
```

This resulted in the error:

```sh
error: access to absolute path '/home' is forbidden in pure evaluation mode (use '--impure' to override)
```

After some troubleshooting, I figured out that this is because the Nix language treats paths and
strings as different types, and that this value should instead be a string:

```nix
users.users = {
  ${username} = {
    home = "/home/${username}";
  }
}
```
