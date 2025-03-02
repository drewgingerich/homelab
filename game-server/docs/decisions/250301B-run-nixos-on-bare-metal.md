# Run NixOS on bare metal

## Decision

Run NixOS on bare metal instead of using Proxmox to run a NixOS VM.

## Side effects

My system will be simpler to reason about and maintain,
especially for IO devices like the GPU.

I will lose Proxmox's tooling for running VMs.

I will lose some conveniences provided by running my server as a VM,
such as being able to reboot it from the Proxmox UI when it hangs.

## Context

I have enjoyed using Proxmox.

Using VMs let me quickly try out several different Linux operating systems.
I have now settled on NixOS.

I also had the idea that using an image-based workflow with something like [Packer](https://www.packer.io/)
would be a good way to keep system state under control,
but I think NixOS does this even better.

The NixOS VM is the only VM I run.

I no longer need the capabilities Proxmox provides.

I'd like to keep my system as simple as possible.
