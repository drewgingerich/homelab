# Enable virtualization

When I tried to start a virtual machine via the Proxmox UI,
it failed with the following error.

```
TASK ERROR: KVM virtualisation configured, but not available. Either disable in VM configuration or enable in BIOS.
```

I do want KVM virtualization, as it looks like the VM performance without it will be poor.
That leaves enabling it in the BIOS.

1. Rebooted computer
2. Entered BIOS during boot
3. Toggled Advanced Mode
4. Navigated to `Tweaker > Advanced CPU Settings`
5. Set `SVM Mode > Enabled`
6. Saved and exited

With virtualization enabled, the VM started successfully.
