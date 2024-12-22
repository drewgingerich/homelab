# Solving PXE boot error for UEFI NixOS VM

I want to explore NixOS.
Since I have a Proxmox server, using a VM seems like a natural choice.

I want to set this VM up for GPU passthrough,
so following [my work to set up the Ubuntu VM](./240219-configure-pci-passthrough-for-gpu#vm-configuration) I set the following settings when creating the VM:

- machine type `q35
- BIOS to `OVFM (UEFI)`

I booted the machine and was met with an error:

```
 BdsDxe: failed to load Boot0002 "UEFI PXEv4" from PciRoot...Access Denied
```

I had to stop the VM, rather than shut it down.

Based on [a Reddit thread](https://www.reddit.com/r/Proxmox/comments/qil7qy/unable_to_pxe_boot_uefibased_vms/) I deleted the EFI Disk in the VM's hardward tab and re-created it,
making sure to uncheck `Pre-Enroll Keys` in the advanced menu.

After than, the VM booted fine!
