[Bazzite](https://bazzite.gg/) is a Linux distro focused on gaming.

I added the Bazzite ISO to Proxmox and created a VM with settings for PCIe passthrough for the GPU.

I followed the graphical setup process.

Steam was already installed.

Tailscale was already installed.
Just needed to start the service with a [one-time auth key](https://tailscale.com/kb/1085/auth-keys).

```sh
sudo tailscale login --authkey=$AUTH_KEY
sudo tailscale up
```

I installed Sunshine using the Bazzite Portal wizard,
making sure to enable automatic start.
I added my Moonlight client using Sunshine's web interface
and it worked great!

I enabled automatic login with:

```
System Settings
> Appearance & Style
> Colors & Themes
> Login Screen (SDDM)
> Behavior
> Automatically log in
> checked
```

I disabled screen locking with:

```
System Settings
> Security & Privacy
> Screen Locking
> Lock screen automatically
> Never
```

Overall super fast to get setup for remotely playing games on Steam.
