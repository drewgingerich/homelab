I want to change my user and group set up.
When I first installed NixOS, I hadn't given much though to it.

NixOS uses the `users.users` attrbute set in the config to create users.
Afterward user create, NixOS allows users to be modified with imperitive commands like `useradd`.
This works well for getting a new system set up, but allows for configuration drift.

https://nlewo.github.io/nixos-manual-sphinx/generated/options-db.xml.html#opt-users-mutableusers

Setting `users.mutableUsers` to `false` makes it so the `/etc/passwd` and `/etc/group` files are recreated every build.
This forces the state of users and groups to align with the NixOS configuration.
It also makes these files readonly and removes imperitive user management commands so they can't be tampered with.
This declarative and immutable approach appeals to me.

https://nlewo.github.io/nixos-manual-sphinx/configuration/user-mgmt.xml.html

Because the user is recreated on every build, changing a password with e.g. `passwd` won't be persisted.
Instead, the password must be set in the Nix configuration file:


```nix
users.users.admin = {
  isNormalUser  = true;
  extraGroups  = [ "wheel" "networkmanager" ];
  password = "wow this is not secure!"
};
```

This might be fine for a private computer with a bespoke configuration file,
but I want to put my configuration in a public Git repo because and I like sharing what I'm working.
I certainly don't want expose my password in plain text.

NixOS provides a `hashedPassword` option to use an encrypted password instead:

```nix
users.users.admin = {
  isNormalUser  = true;
  extraGroups  = [ "wheel" "networkmanager" ];
  hashedPassword = "$6$tnV8pECjl.NwrNG4$h2kTdtahBDsD50gc7Z.AmxBPCO82ziJnMgBxmic35vN5SedqWEk6JlE2gEoSwAbrOuukXULz.BGGrjfTwNxxX/"
};
```

The password hash can be generate using `mkpasswd`:

```sh
mkpasswd -m sha-512
```

[agenix](https://github.com/ryantm/agenix) and [nix-sops](https://github.com/Mic92/sops-nix) are more general secret management tools
for Nix that could also be used here as a solution.

While putting an encrypted secret in a public Git repo is much much better than a plain-text secret,
it's never sat right with me.
At some point current encryption schemes will be broken, and just because a secret is old doesn't mean it has lost its value.

NixOS also provices a `hashedPasswordFile` option that loads an encrypted password from a file.
This side-steps the issue because I can keep the secret file out of version control.
After some thinking, `/var/secrets/<username>_password` seems like a decent location.

```nix
users.users.admin = {
  isNormalUser  = true;
  extraGroups  = [ "wheel" "networkmanager" ];
  hashedPasswordFile = "/var/secrets/admin_password"
};
```

As before, I used `mkpasswd` to encrypt the password before storing it:


```sh
mkpasswd -m sha-512 > /var/secrets/admin_password
```



```sh
sudo usermod -l <new_username> <old_username>
```

One caveat is that when immutable users are configured,
password updates do not persist.
To persist a password change, the new password must be hashed with `mkpasswd -m sha-512`
and used to populate the `hashedPassword` user attribute in the NixOS config.
This means the hashed password will end up in version control.
With strong encryption this is fine, but I would prefer not needing to rely on encryption at all.

An alternative is to provide no password, in which case the user will not have a password.
Passwordless access can be set up using the `openssh.authorizedKeys.keys` user attribute:

```nix
users.users.admin = {
  isNormalUser  = true;
  extraGroups  = [ "wheel" "networkmanager" ];
  openssh.authorizedKeys.keys  = [ "ssh-dss AAAAB3Nza... alice@foobar" ];
};
```


```nix
security.sudo.extraRules = [
  {
    users = [ "admin" ];
    commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; } ];
  }
];
```
