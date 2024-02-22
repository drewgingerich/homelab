# Configure PCI passthrough for the GPU

PCI passthrough allows a GPU (and other devices) to be used directly from within a VM.
This is imporant for performance-critical tasks like gaming.

## IOMMU setup

Following [the PCI passthrough guide on the Proxmox wiki](passthrough-guide),
the first thing to check is the IOMMU capabilities and configuration.

[passthrough-guide]: https://web.archive.org/web/20240203023530/https://pve.proxmox.com/wiki/PCI_Passthrough

By my understanding, drivers for I/O devices like GPUs expect to be able to directly access memory.
This direct memory access is not possible from inside a virtual machine, though, since the memory is virtualized.
If a driver tries to directly access memory, it will likely corrupt the memory
because it doesn't understand the mapping between the virtual and physical memory addresses.

The hypervisor or host OS can perform a translation, but this makes every memory lookup slower.
This performance hit is crippling for performance-centric I/O devices like GPUs.

An IOMMU is a hardware component that, among other things,
translates virtual to physical memory addresses for I/O devices with minimal performance loss[^1][^2][^3].
By using an IOMMU, an I/O device used inside VM can use virtualized memory without taking too much of a performance hit.

To check if my system has an IOMMU, I ran `dmesg | grep -e DMAR -e IOMMU` in a shell on the Proxmox host.
I received:

```sh
AMD-Vi: AMD IOMMUv2 functionality not available on this system - This is not a bug.
```

Well crap!
After some looking around, I found that using the IOMMU is an option that must be enabled in the UEFI firmware settings.

I rebooted and entered the firmware settings.

Following suggestions in a [Reddit post](reddit-enable-iommu),
I set `Settings > AMD CBS > NBIO > IOMMU = Enabled`,
then set `Settings > Miscellaneous > IOMMU = Enabled`,
and finally saved and exited.

[reddit-enable-iommu]: https://web.archive.org/web/20240219190649/https://old.reddit.com/r/gigabyte/comments/12cl7fa/cant_enable_iommu_on_b650m/

Now running `dmesg | grep -e DMAR -e IOMMU` returned a positive result:

```sh
AMD-Vi: AMD IOMMUv2 loaded and initialized
```

Next I checked if IOMMU interrupt remapping is enabled.
PCI devices send data to special memory addresses to trigger interrupts.
These are known as [Message Signaled Interrupts](https://web.archive.org/web/20240115070533/https://en.wikipedia.org/wiki/Message_Signaled_Interrupts).
An IOMMU without interrupt remapping support can't tell if a memory access is meant to be an interrupt or not.

To check, I ran `dmesg | grep 'remapping'` and got:

```sh
AMD-Vi: Interrupt remapping enabled
```

This indicated that interrupt remapping is supported.

Next I checked to see if IOMMU groups are supported.
I ran `pvesh get /nodes/{nodename}/hardware/pci --pci-class-blacklist ""` and got a table of results:

```sh
┌──────────┬────────┬──────────────┬────────────┬────────┬────────────────────────────────────────────────
│ class    │ device │ id           │ iommugroup │ vendor │ device_name
╞══════════╪════════╪══════════════╪════════════╪════════╪════════════════════════════════════════════════
│ 0x010601 │ 0x43f6 │ 0000:0f:00.0 │         25 │ 0x1022 │
├──────────┼────────┼──────────────┼────────────┼────────┼────────────────────────────────────────────────
│ 0x010802 │ 0x1959 │ 0000:02:00.0 │         13 │ 0x1c5c │ Platinum P41 NVMe Solid State Drive 2TB
├──────────┼────────┼──────────────┼────────────┼────────┼────────────────────────────────────────────────
│ 0x020000 │ 0x8125 │ 0000:08:00.0 │         18 │ 0x10ec │ RTL8125 2.5GbE Controller
├──────────┼────────┼──────────────┼────────────┼────────┼────────────────────────────────────────────────
│ 0x028000 │ 0xc852 │ 0000:07:00.0 │         17 │ 0x10ec │
├──────────┼────────┼──────────────┼────────────┼────────┼────────────────────────────────────────────────
│ 0x030000 │ 0x2206 │ 0000:01:00.0 │         12 │ 0x10de │ GA102 [GeForce RTX 3080]
├──────────┼────────┼──────────────┼────────────┼────────┼────────────────────────────────────────────────
```

The `iommugroup` column indicated that IOMMU groups are supported.

## Host setup

I don't want the Proxmox host to load drivers for the GPU because the guest OS will be handling it instead.
To do this, I blacklisted the Nvidia GPU drivers by running:

```sh
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
echo "blacklist nvidia*" >> /etc/modprobe.d/blacklist.conf
```

## References

[^1]: [Input–output memory management unit (Wikipedia)](https://web.archive.org/web/20240201160518/https://en.wikipedia.org/wiki/Input%E2%80%93output_memory_management_unit)
[^2]: [What is IOMMU and how it can be used?](https://web.archive.org/web/20230923133045/https://blog.3mdeb.com/2021/2021-01-13-iommu/)
[^3]: [IOMMU protection against I/O attacks: a vulnerability and a proof of concept](https://web.archive.org/web/20230711052741/https://journal-bcs.springeropen.com/articles/)
