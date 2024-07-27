https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/networking/sunshine.nix

```nix
services.sunshine.enable = true
```

I tried to verify that the Sunshine unit was running, but got a failure: 

```sh
$ sudo systemctl --user --machine=steam@ status sunshine
Failed to connect to bus: No medium found
```

To verify, I checked if the expected port was in use:

```sh
$ sudo ss -tulpn | grep 47989
tcp   LISTEN 0      4096                       0.0.0.0:47989      0.0.0.0:*    users:(("sunshine",pid=1600,fd=36))
```

So Sunshine was running, but not as my user.
I realized that since I had set up autologin for the `steam` user and not my user,
Sunshine was probably running under `steam` instead:

```sh
$ sudo systemctl --user --machine=steam@ status sunshine
● sunshine.service - Self-hosted game stream host for Moonlight
     Loaded: loaded (/etc/systemd/user/sunshine.service; enabled; preset: enabled)
     Active: active (running) since Sat 2024-07-20 19:29:49 PDT; 15min ago
   Main PID: 1600
      Tasks: 15 (limit: 28783)
     Memory: 49.3M (peak: 75.6M)
        CPU: 481ms
     CGroup: /user.slice/user-1002.slice/user@1002.service/app.slice/sunshine.service
             └─1600 /run/wrappers/bin/sunshine
```

Looking good!

To connect the Moonlight client on my laptop I had to input a PIN in the Sunshine web UI.
I didn't want to take the time to connect a display, keyboard, and mouse,
so I used an SSH tunnel to provide access to the web UI:

```sh
ssh -vN -L localhost:8080:localhost:47990 <username>@<server_ip>
```

I could then connect to the Sunshine web UI at `https://localhost:8080`.
Since Sunshine requires using `https`, I had to accept the self-signed certificate to move forward. 

Afterwards I realized I had over-complicated things:
I can actually just connect to the web UI from my laptop by browsing to `https://<local_server_ip>:47990`,
since it's being served like any old webpage.
Cool to refresh my knowledge of SSH tunneling, at least.

The web UI showed an error about needing to add the `CAP_SYS_ADMIN` privileges.
I did this by setting the `capSysAdmin` option: 

```nix
services.sunshine = {
  enabled = true;
  capSysAdmin = true;
};
```

No more errors in the web UI!

I added the server to my Moonlight client using its Tailscale IP address and was able to connect.

