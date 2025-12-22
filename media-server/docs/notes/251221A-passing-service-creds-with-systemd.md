# Passing service credentials with systemd

I want secrets to live outside of my service definitions
so that I can keep them out of version control.

Systemd provide a number of utilities for managing and passing secrets.
Systemd calls secrets _credentials_.

## Passing a single credential

Create a credential.

```sh
sudo mkdir /etc/credstore
echo "Hello from /etc/credstore/sample.txt" | sudo tee /etc/credstore/sample.txt > /dev/null
```

Create a service that loads the credential:

```nix
{ pkgs, ... }:
let
  script = pkgs.writeShellScript "systemd-creds-test.sh" ''
    set -euo pipefail
    ${pkgs.coreutils}/bin/echo $CREDENTIALS_DIRECTORY
    ${pkgs.coreutils}/bin/ls $CREDENTIALS_DIRECTORY
    ${pkgs.coreutils}/bin/cat $CREDENTIALS_DIRECTORY/sample
  '';
in
{
  systemd.services."systemd-creds-test" = {
    enable = true;
    restartIfChanged = true;
    wants = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = script;
      LoadCredential = "sample:/etc/credstore/sample.txt";
    };
  };
}
```

Check output:

```sh
sudo nixos-rebuild switch --flake .
sudo systemctl start systemd-creds-test
sudo systemctl status systemd-creds-test
```

```
○ systemd-creds-test.service
     Loaded: loaded (/etc/systemd/system/systemd-creds-test.service; linked; preset: ignored)
     Active: inactive (dead)

Dec 18 21:44:25 dusty-media-server systemd[1]: Started systemd-creds-test.service.
Dec 18 21:44:25 dusty-media-server 508hh9sv84zh691dg6n8r183lvx5rx7v-systemd-creds-test.sh[2003301]: /run/credentials/systemd-creds-test.service
Dec 18 21:44:25 dusty-media-server 508hh9sv84zh691dg6n8r183lvx5rx7v-systemd-creds-test.sh[2003306]: sample
Dec 18 21:44:25 dusty-media-server 508hh9sv84zh691dg6n8r183lvx5rx7v-systemd-creds-test.sh[2003309]: Hello from /etc/credstore/sample.txt
Dec 18 21:44:25 dusty-media-server systemd[1]: systemd-creds-test.service: Deactivated successfully.
```

## Passing multiple credentials

Create a second credential file:

```sh
echo "Hello from /etc/credstore/sample2.txt" | sudo tee /etc/credstore/sample2.txt > /dev/null
```

Update unit to take both credentials:

```nix
{ pkgs, ... }:
let
  script = pkgs.writeShellScript "systemd-creds-test.sh" ''
    set -euo pipefail
    ${pkgs.coreutils}/bin/echo $CREDENTIALS_DIRECTORY
    ${pkgs.coreutils}/bin/ls $CREDENTIALS_DIRECTORY
    ${pkgs.coreutils}/bin/cat $CREDENTIALS_DIRECTORY/sample
    ${pkgs.coreutils}/bin/cat $CREDENTIALS_DIRECTORY/sample2
  '';
in
{
  systemd.services."systemd-creds-test" = {
    enable = true;
    restartIfChanged = true;
    wants = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = script;
      LoadCredential = [
        "sample:/etc/credstore/sample.txt"
        "sample2:/etc/credstore/sample2.txt"
      ];
    };
  };
}
```

Check output:

```sh
sudo nixos-rebuild switch --flake .
sudo systemctl start systemd-creds-test
sudo systemctl status systemd-creds-test
```

```
○ systemd-creds-test.service
     Loaded: loaded (/etc/systemd/system/systemd-creds-test.service; linked; preset: ignored)
     Active: inactive (dead)

Dec 18 21:56:15 dusty-media-server 6fxh3afciima2479qis7535nl408dnk8-systemd-creds-test.sh[2014530]: /run/credentials/systemd-creds-test.service
Dec 18 21:56:15 dusty-media-server 6fxh3afciima2479qis7535nl408dnk8-systemd-creds-test.sh[2014542]: sample
Dec 18 21:56:15 dusty-media-server 6fxh3afciima2479qis7535nl408dnk8-systemd-creds-test.sh[2014542]: sample2
Dec 18 21:56:15 dusty-media-server 6fxh3afciima2479qis7535nl408dnk8-systemd-creds-test.sh[2014544]: Hello from /etc/credstore/sample.txt
Dec 18 21:56:15 dusty-media-server 6fxh3afciima2479qis7535nl408dnk8-systemd-creds-test.sh[2014545]: Hello from /etc/credstore/sample2.txt
Dec 18 21:56:15 dusty-media-server systemd[1]: systemd-creds-test.service: Deactivated successfully.`
```

Alternatively, pass credential directory:

```nix
{ pkgs, ... }:
let
  script = pkgs.writeShellScript "systemd-creds-test.sh" ''
    set -euo pipefail
    ${pkgs.coreutils}/bin/echo $CREDENTIALS_DIRECTORY
    ${pkgs.coreutils}/bin/ls $CREDENTIALS_DIRECTORY
    ${pkgs.coreutils}/bin/cat $CREDENTIALS_DIRECTORY/sample
    ${pkgs.coreutils}/bin/cat $CREDENTIALS_DIRECTORY/sample2
  '';
in
{
  systemd.services."systemd-creds-test" = {
    enable = true;
    restartIfChanged = true;
    wants = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = script;
      LoadCredential = "/etc/credstore";
    };
  };
}
```

Check output:

```sh
sudo nixos-rebuild switch --flake .
sudo systemctl start systemd-creds-test
sudo systemctl status systemd-creds-test
```

```
○ systemd-creds-test.service
     Loaded: loaded (/etc/systemd/system/systemd-creds-test.service; linked; preset: ignored)
     Active: inactive (dead)

Dec 18 21:56:15 dusty-media-server 6fxh3afciima2479qis7535nl408dnk8-systemd-creds-test.sh[2014530]: /run/credentials/systemd-creds-test.service
Dec 18 21:56:15 dusty-media-server 6fxh3afciima2479qis7535nl408dnk8-systemd-creds-test.sh[2014542]: sample
Dec 18 21:56:15 dusty-media-server 6fxh3afciima2479qis7535nl408dnk8-systemd-creds-test.sh[2014542]: sample2
Dec 18 21:56:15 dusty-media-server 6fxh3afciima2479qis7535nl408dnk8-systemd-creds-test.sh[2014544]: Hello from /etc/credstore/sample.txt
Dec 18 21:56:15 dusty-media-server 6fxh3afciima2479qis7535nl408dnk8-systemd-creds-test.sh[2014545]: Hello from /etc/credstore/sample2.txt
Dec 18 21:56:15 dusty-media-server systemd[1]: systemd-creds-test.service: Deactivated successfully.`
```

## Automated credential lookup

Systemd can automatically find credentials stored in the well-know locations.

```sh
# for system units
systemd-path system-search-credential-store system-search-credential-store-encrypted

# for user units
systemd-path user-search-credential-store user-search-credential-store-encrypted
```

Create a secret in the system credential store.

```sh
sudo mkdir -p /etc/credstore/test
echo "Hello from /etc/credstore/hello" | sudo tee /etc/credstore/hello > /dev/null
```

```nix
{ pkgs, ... }:
let
  script = pkgs.writeShellScript "systemd-creds-test.sh" ''
    set -euo pipefail
    ${pkgs.coreutils}/bin/echo $CREDENTIALS_DIRECTORY
    ${pkgs.coreutils}/bin/ls $CREDENTIALS_DIRECTORY
    ${pkgs.coreutils}/bin/cat $CREDENTIALS_DIRECTORY/hello
  '';
in
{
  systemd.services."systemd-creds-test" = {
    enable = true;
    restartIfChanged = true;
    wants = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = script;
      LoadCredential = "hello";
    };
  };
}
```

```sh
sudo nixos-rebuild switch --flake .
sudo systemctl start systemd-creds-test
sudo systemctl status systemd-creds-test
```

```
○ systemd-creds-test.service
     Loaded: loaded (/etc/systemd/system/systemd-creds-test.service; linked; preset: ignored)
     Active: inactive (dead)

Dec 21 18:45:17 dusty-media-server systemd[1]: Started systemd-creds-test.service.
Dec 21 18:45:17 dusty-media-server wsarm5rkrdx80glqg061py58p04018id-systemd-creds-test.sh[879623]: /run/credentials/systemd-creds-test.service
Dec 21 18:45:17 dusty-media-server wsarm5rkrdx80glqg061py58p04018id-systemd-creds-test.sh[879625]: hello
Dec 21 18:45:17 dusty-media-server wsarm5rkrdx80glqg061py58p04018id-systemd-creds-test.sh[879626]: Hello from /etc/credstore/hello
Dec 21 18:45:17 dusty-media-server systemd[1]: systemd-creds-test.service: Deactivated successfully.
```

My understanding is that this only works for files directly under these well-known directories,
and not in nested directories.

A common way to namespace credential files is to use the format `<domain>.<cred_name>`,
such as `plex.claim` or `nextcloud.database_password`.

## Resources

- https://systemd.io/CREDENTIALS/
- https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#Credentials
- https://partial.solutions/2024/understanding-systemd-credentials.html
