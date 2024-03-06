# Configure PCIe passthrough for the GPU

PCIe passthrough allows IO devices like a GPU to be used directly by a VM,
instead of the VM interacting with it through a software virtualization layer.
This is imporant for performance-critical tasks like gaming.

I've found several guides for setting up PCI passthrough for a GPU:
- [VFIO GPU How To Series (Alex Williamson)](https://vfio.blogspot.com/2015/05/vfio-gpu-how-to-series-part-1-hardware.html)
- [PCI/GPU Passthrough on Proxmox VE 8 : Installation and configuration (Proxmox forum)](https://forum.proxmox.com/threads/pci-gpu-passthrough-on-proxmox-ve-8-installation-and-configuration.130218/)
- [PCI passthrough via OVMF (Arch Linux wiki)](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF)
- [PCI(e) Passthrough (Proxmox wiki)](https://web.archive.org/web/20240224170249/https://pve.proxmox.com/wiki/PCI%28e%29_Passthrough)

The high-level steps are:
1. Enable and configure IOMMU
1. Prevent host from binding drivers to the GPU
1. Configure virtualization to pass GPU through to guest
1. Configure guest to bind drivers to the GPU

## IOMMU setup

I'm starting by checking the IOMMU capabilities and configuration of my system.

I/O devices like GPUs need to access memory.
Within a virtual machine, I/O devices access memory via veritualized memory addresses that must be translated to physical addresses.
The hypervisor can do this translation, but with the cost of delaying every memory access.
This performance hit is crippling for performance-centric I/O devices like GPUs.

An input-output memory management unit (IOMMU) is a hardware component that, among other things,
translates virtual to physical memory addresses for I/O devices with minimal performance loss[^1][^2][^3].
The hypervisor can outsource the address translation to the IOMMU to keep performance high.

Running `dmesg | grep -e DMAR -e IOMMU` in a shell on the Proxmox host gives:

```sh
AMD-Vi: AMD IOMMUv2 functionality not available on this system - This is not a bug.
```

Well crap!
After some looking around, I find that using the IOMMU is an option that must be enabled in the UEFI firmware settings.

I reboot and enter the firmware settings.

Following suggestions in a [Reddit post](reddit-enable-iommu),
I set `Settings > AMD CBS > NBIO > IOMMU = Enabled`,
then set `Settings > Miscellaneous > IOMMU = Enabled`,
and finally save and exit.

[reddit-enable-iommu]: https://web.archive.org/web/20240219190649/https://old.reddit.com/r/gigabyte/comments/12cl7fa/cant_enable_iommu_on_b650m/

Now running `dmesg | grep -e DMAR -e IOMMU` returns a positive result:

```sh
AMD-Vi: AMD IOMMUv2 loaded and initialized
```

Next I'll check if IOMMU interrupt remapping is available and enabled.

PCIe devices trigger interrupts by sending messages to special memory addresses,
a process known as [Message Signaled Interrupts](wikipedia-msi).
Devices passed through to a VM could be used to send arbitrary interrupt messages,
which are potentially useful for a variety of exploits[^4].
IOMMU interrupt remapping is a mechanism that allows the host to restrict which interrupts devices are allowed to send, 
closing this attack vector.

[wikipedia-msi](https://web.archive.org/web/20240115070533/https://en.wikipedia.org/wiki/Message_Signaled_Interrupts)

Running `dmesg | grep 'remapping'` gives:

```sh
AMD-Vi: Interrupt remapping enabled
```

This indicates that interrupt remapping is supported.

Next I'll check to see if IOMMU groups are supported.
IOMMU groups are how the IOMMU isolates various groups of devices from other groups[^5][^6][^7].

When PCI devices share an I/O virtual address (IOVA) space,
they can accidentally or maliciously access each other's memory.
To avoid this, the IOMMU can assign each device a different IOVA space.

PCIe devices can also communicate with other devices directly, without going through the IOMMU.
This bypasses the isolation provided by using separate IOVA spaces.
Modern PCIe hardware implement PCIe Access Control Services (ACS), which can prevent devices from talking with each other.
ACS can prevent cross-device communication and regain the isolation provided by separate IOVA spaces.

ACS doesn't block all cross-device communication, however.
Some devices must be able to talk to each other for functionality or performance.
GPU cards generally come with an audio controller as well as the graphics card,
and these must communicate with each other to provide audio and visual over HDMI or display port, for example.
Other devices are so old that ACS can't be properly set up,
Such as PCI devices made before ACS was part of the PCIe specification.
When devices can't be fully isolated, ACS can still isolate them in minimal groups to provide a degree of isolation.

The IOMMU provides a separate IOVA space for each of these groups.
These groups are known as IOMMU groups.

IOMMU groups must be passed into a VM as a whole.
If a subset of the devices in an IOMMU group were passed into a VM,
they could break through the virtualization layer by communicating with the devices that were not passed through.

IOMMU groups are determined automatically by the kernel.
Ideally the GPU I want to pass to the VM is in its own IOMMU group,
otherwise I'll have to pass in unneeded devices.

Running `pvesh get /nodes/$(hostname)/hardware/pci --pci-class-blacklist ""` yields this table of results (cropped):

```sh
┌──────────┬────────┬──────────────┬────────────┬────────┬───────────────────────────────────────────────────
│ class    │ device │ id           │ iommugroup │ vendor │ device_name                                        
╞══════════╪════════╪══════════════╪════════════╪════════╪═══════════════════════════════════════════════════
│ 0x010601 │ 0x43f6 │ 0000:0f:00.0 │         25 │ 0x1022 │                                                    
├──────────┼────────┼──────────────┼────────────┼────────┼───────────────────────────────────────────────────
│ 0x010802 │ 0x1959 │ 0000:02:00.0 │         13 │ 0x1c5c │ Platinum P41 NVMe Solid State Drive 2TB            
├──────────┼────────┼──────────────┼────────────┼────────┼───────────────────────────────────────────────────
│ 0x020000 │ 0x8125 │ 0000:08:00.0 │         18 │ 0x10ec │ RTL8125 2.5GbE Controller                          
├──────────┼────────┼──────────────┼────────────┼────────┼───────────────────────────────────────────────────
│ 0x028000 │ 0xc852 │ 0000:07:00.0 │         17 │ 0x10ec │                                                    
├──────────┼────────┼──────────────┼────────────┼────────┼───────────────────────────────────────────────────
│ 0x030000 │ 0x2206 │ 0000:01:00.0 │         12 │ 0x10de │ GA102 [GeForce RTX 3080]                           
├──────────┼────────┼──────────────┼────────────┼────────┼───────────────────────────────────────────────────
│ 0x030000 │ 0x164e │ 0000:10:00.0 │         26 │ 0x1002 │ Raphael                                            
├──────────┼────────┼──────────────┼────────────┼────────┼───────────────────────────────────────────────────
│ 0x040300 │ 0x1aef │ 0000:01:00.1 │         12 │ 0x10de │ GA102 High Definition Audio Controller             
├──────────┼────────┼──────────────┼────────────┼────────┼───────────────────────────────────────────────────
│ 0x040300 │ 0x1640 │ 0000:10:00.1 │         27 │ 0x1002 │ Rembrandt Radeon High Definition Audio Controller  
├──────────┼────────┼──────────────┼────────────┼────────┼───────────────────────────────────────────────────
│ 0x040300 │ 0x15e3 │ 0000:10:00.6 │         31 │ 0x1022 │ Family 17h/19h HD Audio Controller                
```

The `iommugroup` column indicates my motherboard and IOMMU supports IOMMU groups.
It also shows that my GPU (`0000:01:00.0`) and its audio controller (`0000:01:00.1`) are together in group 12,
and that they are the only devices in group 12.

With all of that, I've verified that my system supports all of the IOMMU-related things necessary for GPU-passthrough.

## Host setup

Because GPUs are complicated, they generally don't handle rebinding drivers well.
To bind the GPU to drivers in the VM, I want to avoid having the host bind drivers to it first.

To do this, I blacklist the Nvidia GPU drivers by running:

```sh
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
echo "blacklist nvidia*" >> /etc/modprobe.d/blacklist.conf
```

## References

[^0]: [An Introduction to IOMMU Infrastructure in the Linux Kernel](https://web.archive.org/web/2/https://lenovopress.lenovo.com/lp1467.pdf)
[^1]: [Input–output memory management unit (Wikipedia)](https://web.archive.org/web/20240201160518/https://en.wikipedia.org/wiki/Input%E2%80%93output_memory_management_unit)
[^2]: [What is IOMMU and how it can be used?](https://web.archive.org/web/20230923133045/https://blog.3mdeb.com/2021/2021-01-13-iommu/)
[^3]: [IOMMU protection against I/O attacks: a vulnerability and a proof of concept](https://web.archive.org/web/20230711052741/https://journal-bcs.springeropen.com/articles/)
[^4]: [Following the White Rabbit: Software attacks against Intel (R) VT-d technology](https://web.archive.org/web/20230711052741mp_/http://www.invisiblethingslab.com/resources/2011/Software%2520Attacks%2520on%2520Intel%2520VT-d.pdf)
[^5]: [IOMMU Groups – What You Need to Consider](https://web.archive.org/web/20230928084315/https://www.heiko-sieger.info/iommu-groups-what-you-need-to-consider/)
[^6]: [IOMMU Groups, inside and out](https://web.archive.org/web/20240223082856/http://vfio.blogspot.com/2014/08/iommu-groups-inside-and-out.html)
[^7]: [VFIO - "Virtual Function I/O" (Linux Kernel documentation)](https://www.kernel.org/doc/Documentation/vfio.txt)

[PCI Express Access Control Services (ACS)](https://web.archive.org/web/2/https://pdos.csail.mit.edu/~sbw/links/ECN_access_control_061011.pdf)
[PCI Express® Base Specification Revision 5.0 Version 1.0](https://web.archive.org/web/20240107173049/https://picture.iczhiku.com/resource/eetop/SYkDTqhOLhpUTnMx.pdf)

https://www.linux-kvm.org/downloads/lersek/ovmf-whitepaper-c770f8c.txt
