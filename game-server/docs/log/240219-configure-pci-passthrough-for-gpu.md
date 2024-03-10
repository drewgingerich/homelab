# Configure PCIe passthrough for the GPU

PCIe passthrough allows IO devices like a GPU to be used directly by a VM,
instead of the VM interacting with it through a software virtualization layer.
This is imporant for performance-critical tasks like gaming.

I found several guides for setting up PCI passthrough for a GPU:
- [PCI(e) Passthrough (Proxmox wiki)](https://web.archive.org/web/20240224170249/https://pve.proxmox.com/wiki/PCI%28e%29_Passthrough)
- [PCI passthrough via OVMF (Arch Linux wiki)](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF)
- [VFIO GPU How To Series (Alex Williamson)](https://vfio.blogspot.com/2015/05/vfio-gpu-how-to-series-part-1-hardware.html)
- [PCI/GPU Passthrough on Proxmox VE 8 : Installation and configuration (Proxmox forum)](https://forum.proxmox.com/threads/pci-gpu-passthrough-on-proxmox-ve-8-installation-and-configuration.130218/)

The high-level steps are:
1. Enable and configure the IOMMU for passthrough mode
1. Prevent the host from binding drivers to the GPU
1. Configure the VM for PCI passthrough

## IOMMU setup

I/O devices like GPUs need to access memory.
Within a virtual machine, I/O devices access memory via virtualized memory addresses that must be translated to physical addresses.
The hypervisor can do this translation, but at the cost of delaying every memory access.
This performance hit is crippling for performance-centric I/O devices like GPUs.

An input-output memory management unit (IOMMU) is a hardware component that, among other things,
translates virtual to physical memory addresses for I/O devices with minimal performance loss[^1][^2][^3][^4].
I want to configure the system so the hypervisor outsources address translation to the IOMMU to keep performance high.

I started by checking the IOMMU capabilities and configuration of my system.
Running `dmesg | grep -e DMAR -e IOMMU` in a shell on the Proxmox host gave:

```sh
AMD-Vi: AMD IOMMUv2 functionality not available on this system - This is not a bug.
```

Well crap!
After some looking around, I found that using the IOMMU is an option that must be enabled in the UEFI firmware settings.

I rebooted and entered the firmware settings.

Following suggestions in a [Reddit post](reddit-enable-iommu),
I set `Settings > AMD CBS > NBIO > IOMMU = Enabled`,
then set `Settings > Miscellaneous > IOMMU = Enabled`,
and finally save and exit.

[reddit-enable-iommu]: https://web.archive.org/web/20240219190649/https://old.reddit.com/r/gigabyte/comments/12cl7fa/cant_enable_iommu_on_b650m/

Now running `dmesg | grep -e DMAR -e IOMMU` returned a positive result:

```sh
AMD-Vi: AMD IOMMUv2 loaded and initialized
```

Next I checked if IOMMU interrupt remapping is available and enabled.

PCIe devices trigger interrupts by sending messages to special memory addresses,
a process known as [Message Signaled Interrupts](wikipedia-msi).
Devices passed through to a VM could be used to send arbitrary interrupt messages,
which are potentially useful for a variety of exploits[^5].
IOMMU interrupt remapping is a mechanism that allows the host to restrict which interrupts devices are allowed to send, 
closing this attack vector.

[wikipedia-msi](https://web.archive.org/web/20240115070533/https://en.wikipedia.org/wiki/Message_Signaled_Interrupts)

Running `dmesg | grep 'remapping'` gave:

```sh
AMD-Vi: Interrupt remapping enabled
```

This indicates that interrupt remapping is supported.

Next I checked to see if IOMMU groups are supported.
IOMMU groups are how the IOMMU isolates various groups of devices from other groups[^6][^7][^8].

When PCI devices share an I/O virtual address (IOVA) space,
they can accidentally or maliciously access each other's memory.
To avoid this, the IOMMU can assign each device a different IOVA space.

PCIe devices can also communicate with other devices directly, without going through the IOMMU.
This bypasses the isolation provided by using separate IOVA spaces.
Modern PCIe hardware implements PCIe Access Control Services (ACS) to regular how PCIe devices communicate with each other.
ACS can shut down cross-device communication to support the isolation provided by using separate IOVA spaces.

ACS can't block all cross-device communication, however.
Some devices must be able to talk to each other for functionality or performance.
GPU cards come with an audio controller that works with the graphics card
to provide combined audio and visual over HDMI or display port, for example.
Other devices are so old that ACS can't be properly set up,
Such as PCI devices made before ACS was part of the PCIe specification.

When devices can't be fully isolated, ACS can still isolate them in minimal groups.
Since devices within a group are not isolated from each other,
the IOMMU provides one IOVA space per groups.
Groups that the IOMMU treats as one set are called IOMMU groups.

IOMMU groups must be passed into a VM as a whole.
If a subset of the devices in an IOMMU group were passed into a VM,
they could break through the virtualization layer by communicating with the devices that were not passed through.

IOMMU groups are determined automatically by the kernel.
Devices that are being passed to a VM ideally don't have any additional devices in their IOMMU groups,
otherwise those additional devices have to be passed in as well.

Running `pvesh get /nodes/$(hostname)/hardware/pci --pci-class-blacklist ""` yielded this table of results (cropped):

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

The last thing to do is to turn on IOMMU passthrough mode,
which lets the IOMMU handle the translation of virtual to physical addresses for PCI-passthrough devices instead of the hypervisor.

Lastly I want to turn on IOMMU passthrough mode, which lets the GPU communicate directly with the IOMMU
rather than having each memory access translated by the hypervisor.
This is the source of the performance gain from using the IOMMU, so this step is important!
On modern systems, passthrough mode is the default mode of the IOMMU.

I added `iommu=pt` to the `GRUB_CMDLINE_LINUX_DEFAULT` variable in `/etc/default/grub`.
I ran `update-initramfs -u -k all` to load this changes.

With all of that, I verified that my system supports all of the IOMMU-related things necessary for GPU-passthrough.

## Host setup

Because GPUs are complicated, they generally don't handle driver rebinding well.
If the VM has to rebind a GPU that was previous bound by the host, it probably won't work. 
To allow the VM to bind the GPU, then, the host should be prevented from binding it first.

There is actually a `vfio-pci` driver designed for this situation.
The host can bind the GPU to this driver, and the VM can bind a native driver on top.
The advantage here is that the `vfio-pci` driver still give the host some basic control over the device,
such as being able to set it into a low power state when the VM isn't running.

To make the `vfio-pci` driver accessible I added the following to `/etc/modules`:

```
vfio
vfio_iommu_type1
vfio_pci
```

The `vfio-pci` driver doesn't have high priority,
so I also blacklisted the default Nvidia GPU drivers by running:

```sh
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
echo "blacklist nvidia*" >> /etc/modprobe.d/blacklist.conf
```

I ran `update-initramfs -u -k all` and rebooted to update the kernel.

I ran `lsmod | grep vfio` to verify the VFIO-related modules loaded.

With `vfio-pci` being the only suitable driver left,
the system should bind it to the GPU.

Running `lspci -nnk` showed that, indeed, the graphics card is bound to the `vfio-pci` driver.

```
...
01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GA102 [GeForce RTX 3080] [10de:2206] (rev a1)
        Subsystem: ZOTAC International (MCO) Ltd. GA102 [GeForce RTX 3080] [19da:1612]
        Kernel driver in use: vfio-pci
        Kernel modules: nvidiafb, nouveau
01:00.1 Audio device [0403]: NVIDIA Corporation GA102 High Definition Audio Controller [10de:1aef] (rev a1)
        Subsystem: ZOTAC International (MCO) Ltd. GA102 High Definition Audio Controller [19da:1612]
        Kernel driver in use: vfio-pci
        Kernel modules: snd_hda_intel
...
```

This also showed that the audio controller got bound to the `snd_hda_intel` driver.
This ended up working fine, presumably because the audio controller is not sensitive to being re-bound the way the GPU is.

## VM configuration

Following the Proxmox PCIe passthrough guide,
while creating the VM I set the machine type to `q35` and the BIOS to `OVFM (UEFI)`.
I also set the EFI Storage to `local-lvm` and de-selected `start on boot`.

In hardware tab of the web UI for the new VM, I added the GPU as PCI device.
I selected the GPU from the menu and checked the `All Functions` box to pass the audio controller through as well.
I also `PCI-Express` box under the advanced menu as well.

At this point the VM would boot and reach the login screen,
but login would fail and the login screen would appear again.

This ended up being because I was doing this through the Proxmox web console.
As I had seen in some of the guides, and as my experience friend let me know,
GPU passthrough has some sort of conflict with the web console.
Now that the GPU was being passed, I'd have to work with the VM using a physical display.

In the Proxmox web UI > VM > hardware tab I edited the value of Display to be `none`.
Also passed two USB ports to the VM, for a mouse and keyboard.

## Setting up remote access

With this physical KVM setup I was able to log in fine, and everything seemed to be working!

The whole point of this computer is to not need to be next to it to use it, though,
so I set up Tailscale and SSH to remotely administer this VM.

Following [Tailscale's Ubuntu 22 installation guide](https://tailscale.com/kb/1187/install-ubuntu-2204):

```
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt update
sudo apt install tailscale
sudo tailscale up
```

And to install the SSH server I ran:

```
sudo apt update
sudo apt install openssh-server
```

Now I could SSH in for remote administration and to set up some way to stream games remotely.

## References

[^1]: [An Introduction to IOMMU Infrastructure in the Linux Kernel](https://web.archive.org/web/2/https://lenovopress.lenovo.com/lp1467.pdf)
[^2]: [Input–output memory management unit (Wikipedia)](https://web.archive.org/web/20240201160518/https://en.wikipedia.org/wiki/Input%E2%80%93output_memory_management_unit)
[^3]: [What is IOMMU and how it can be used?](https://web.archive.org/web/20230923133045/https://blog.3mdeb.com/2021/2021-01-13-iommu/)
[^4]: [IOMMU protection against I/O attacks: a vulnerability and a proof of concept](https://web.archive.org/web/20230711052741/https://journal-bcs.springeropen.com/articles/)
[^5]: [Following the White Rabbit: Software attacks against Intel (R) VT-d technology](https://web.archive.org/web/20230711052741mp_/http://www.invisiblethingslab.com/resources/2011/Software%2520Attacks%2520on%2520Intel%2520VT-d.pdf)
[^6]: [IOMMU Groups – What You Need to Consider](https://web.archive.org/web/20230928084315/https://www.heiko-sieger.info/iommu-groups-what-you-need-to-consider/)
[^7]: [IOMMU Groups, inside and out](https://web.archive.org/web/20240223082856/http://vfio.blogspot.com/2014/08/iommu-groups-inside-and-out.html)
[^8]: [VFIO - "Virtual Function I/O" (Linux Kernel documentation)](https://www.kernel.org/doc/Documentation/vfio.txt)
[^9]: [Open Virtual Machine Firmware (OVMF) Status Report](https://www.linux-kvm.org/downloads/lersek/ovmf-whitepaper-c770f8c.txt)

[PCI Express Access Control Services (ACS)](https://web.archive.org/web/2/https://pdos.csail.mit.edu/~sbw/links/ECN_access_control_061011.pdf)
[PCI Express® Base Specification Revision 5.0 Version 1.0, Chapter 6](https://web.archive.org/web/20240107173049/https://picture.iczhiku.com/resource/eetop/SYkDTqhOLhpUTnMx.pdf)

