# Configure PCI passthrough for the GPU

PCI passthrough allows a GPU (and other devices) to be used directly from within a VM.
This is imporant for performance-critical tasks like gaming.

## Enable IOMMU in UEFI firmware settings

Following [the PCI passthrough guide on the Proxmox wiki](https://web.archive.org/web/20240203023530/https://pve.proxmox.com/wiki/PCI_Passthrough),
I checked to see if [IOMMU](https://web.archive.org/web/20240201160518/https://en.wikipedia.org/wiki/Input%E2%80%93output_memory_management_unit) is enabled.

By my understanding, drivers for IO devices like GPUs expect to be able to directly access memory.
This direct memory access is not possible from inside a virtual machine, though, since the memory is virtualized.
If a driver tries to directly access memory,it will likely corrupt the memory
because it doesn't understand the mapping between the virtual and physical memory addresses.

The hypervisor or host OS can perform a translation, but this adds latency to every memory lookup.
This additional latency is crippling for high-performance IO devices like GPUs.
An IOMMU is a hardware component that, among other things,
translates virtual to physical memory addresses for IO devices with minimal extra latency.

To check if my system has an IOMMU, host I ran `dmesg | grep -e DMAR -e IOMMU` in a shell on the Proxmox host.
I received:

```sh
AMD-Vi: AMD IOMMUv2 functionality not available on this system - This is not a bug.
```

Well crap! After some looking around, I saw that using the IOMMU is an option that must be enabled in the BIOS.

I rebooted and entered the UEFI firmware settings.

Following suggestions in a [Reddit post](https://web.archive.org/web/20240219190649/https://old.reddit.com/r/gigabyte/comments/12cl7fa/cant_enable_iommu_on_b650m/),
I set `Settings > AMD CBS > NBIO > IOMMU = Enabled`,
then set `Settings > Miscellaneous > IOMMU = Enabled`,
and then saved and exited.

Now running `dmesg | grep -e DMAR -e IOMMU` returned a positive result:

```sh
AMD-Vi: AMD IOMMUv2 loaded and initialized
```
