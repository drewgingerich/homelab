# Configure PCIe passthrough for the GPU

PCIe passthrough allows IO devices like a GPU to be used directly by a VM,
instead of the VM interacting with it through a software virtualization layer.
This is imporant for performance-critical tasks like gaming.

I'm following the [PCI Passthrough](passthrough-guide) and [PCI(e) Passthrough](passthrough-guide), guide on the Proxmox wiki

[proxmox-guide-1]: https://web.archive.org/web/20240203023530/https://pve.proxmox.com/wiki/PCI_Passthrough
[proxmox-guide-2]: https://web.archive.org/web/20240224170249/https://pve.proxmox.com/wiki/PCI%28e%29_Passthrough

## IOMMU setup

I'm starting by checking the IOMMU capabilities and configuration of my system.

I/O devices like GPUs need to access memory.
Within a virtual machine, I/O devices access memory via veritualized memory addresses that must be translated to physical addresses.
The hypervisor can do this translation, but with the cost of delaying every memory access.
This performance hit is crippling for performance-centric I/O devices like GPUs.

An input-output memory management unit (IOMMU) is a hardware component that, among other things,
translates virtual to physical memory addresses for I/O devices with minimal performance loss[^1][^2][^3].
The hypervisor can outsource the address translation to the IOMMU to keep performance high.

I run `dmesg | grep -e DMAR -e IOMMU` in a shell on the Proxmox host and receive:

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

Next I check if IOMMU interrupt remapping is available and enabled.

PCIe devices trigger interrupts by sending messages to special memory addresses,
a process known as [Message Signaled Interrupts](wikipedia-msi).
Devices passed through to a VM could be used to send arbitrary interrupt messages,
which are potentially useful for a variety of exploits[^4].
IOMMU interrupt remapping is a mechanism that allows the host to restrict which interrupts devices are allowed to send, 
closing this attack vector.

[wikipedia-msi](https://web.archive.org/web/20240115070533/https://en.wikipedia.org/wiki/Message_Signaled_Interrupts)

I run `dmesg | grep 'remapping'` and get:

```sh
AMD-Vi: Interrupt remapping enabled
```

This indicates that interrupt remapping is supported.

Next I check to see if IOMMU groups are supported.
IOMMU groups are a way to isolate I/O devices from each other[^5][^6].
What gets passed into the VM is actually the IOMMU group, rather than the device directly.

I run `pvesh get /nodes/{nodename}/hardware/pci --pci-class-blacklist ""` and get this table of results (cropped):

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

The `iommugroup` column indicates that IOMMU groups are supported.
It also shows that my GPUl (`0000:01:00.0`) and its audio controller (`0000:01:00.1`) are together in group 12.
Inspecting the rest of the table, these are the only devices in this group.
This is good, because I don't want to pass anything else into the VM.

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
[^4]: [Following the White Rabbit: Software attacks against Intel (R) VT-d technology](https://web.archive.org/web/20230711052741mp_/http://www.invisiblethingslab.com/resources/2011/Software%2520Attacks%2520on%2520Intel%2520VT-d.pdf)
[^5]: [IOMMU Groups – What You Need to Consider](https://web.archive.org/web/20230928084315/https://www.heiko-sieger.info/iommu-groups-what-you-need-to-consider/)
[^6]: [IOMMU Groups, inside and out](https://web.archive.org/web/20240223082856/http://vfio.blogspot.com/2014/08/iommu-groups-inside-and-out.html)
