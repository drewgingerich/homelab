# NixOS: Passwordless sudo for user

```nix
security.sudo.extraRules = [
  {
    users = [ "drew" ];
    commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; } ];
  }
];
```
