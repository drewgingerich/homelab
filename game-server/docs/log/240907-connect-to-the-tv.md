I [recently decided](/game-server/docs/decisions/240706-directly-connect-server-and-tv.md) to directly wire my game server to my TV.

Since the TV only has HDMI ports, I got a long HDMI cable.

Since the GPU only has one HDMI port and it's being used by the HDMI dummy plug,
I got a [$6 FUERAN 1080p DP dummy plug](https://www.amazon.com/dp/B071CGCTMY) instead.
After swapping the dummy plugs and rebooting the VM,
the Display Port dummy plug worked without issue.

After plugging the HDMI cable into the server and TV,
a second desktop appeared on the TV.
I mirrored the displays.

For the USB I hooked up the ezcoo USB-over-ethernet extender.
I also purchased a generic Bluetooth receiver and a Bluetooth keyboard,
and plugged both dongles into the ezcoo HUB near the TV.

I still needed to pass the USB through to the VM.
I could pass specific USB devices through,
but I thought it would best nicer in the long run to pass through a whole USB controller.
To do this, I needed to find the device ID of the USB controller.
On the host Proxmox server:

```sh
$ readlink /sys/bus/usb/devices/usb*
../../../devices/pci0000:00/0000:00:02.1/0000:03:00.0/0000:04:0c.0/0000:0e:00.0/usb1
../../../devices/pci0000:00/0000:00:02.1/0000:03:00.0/0000:04:0c.0/0000:0e:00.0/usb2
../../../devices/pci0000:00/0000:00:08.1/0000:10:00.3/usb3
../../../devices/pci0000:00/0000:00:08.1/0000:10:00.3/usb4
../../../devices/pci0000:00/0000:00:08.1/0000:10:00.4/usb5
../../../devices/pci0000:00/0000:00:08.1/0000:10:00.4/usb6
../../../devices/pci0000:00/0000:00:08.3/0000:11:00.0/usb7
../../../devices/pci0000:00/0000:00:08.3/0000:11:00.0/usb8
```

The device ID is the second to last path segment.

Next I wanted to check if any of these devices were alone in an IOMMU group.
Since everything in an IOMMU group must be passed through together,
I wanted to avoid having to pass in extra devices.

To get the IOMMU group by device ID, e.g. `0000:10:00.3`:

```sh
$ find /sys/kernel/iommu_groups/* -type l | grep "0000:10:00.3"
/sys/kernel/iommu_groups/29/devices/0000:10:00.3
```

To get all devices in an IOMMU group, e.g. `17`:

```sh
$ find /sys/kernel/iommu_groups/17 -type l
/sys/kernel/iommu_groups/17/devices/0000:04:02.0
/sys/kernel/iommu_groups/17/devices/0000:07:00.0
```

I had to run this a few times to evaluate the 4 USB devices:

```sh
$ find /sys/kernel/iommu_groups/* -type l | grep "0000:0e:00.0"
/sys/kernel/iommu_groups/24/devices/0000:0e:00.0
$ find /sys/kernel/iommu_groups/24 -type l
/sys/kernel/iommu_groups/24/devices/0000:0e:00.0
/sys/kernel/iommu_groups/24/devices/0000:04:0c.0

$ find /sys/kernel/iommu_groups/* -type l | grep "0000:10:00.4"
/sys/kernel/iommu_groups/30/devices/0000:10:00.4
$ find /sys/kernel/iommu_groups/30 -type l
/sys/kernel/iommu_groups/30/devices/0000:10:00.4

$ find /sys/kernel/iommu_groups/* -type l | grep "0000:10:00.3"
/sys/kernel/iommu_groups/29/devices/0000:10:00.3
$ find /sys/kernel/iommu_groups/29 -type l
/sys/kernel/iommu_groups/29/devices/0000:10:00.3

$ find /sys/kernel/iommu_groups/* -type l | grep "0000:11:00.0"
/sys/kernel/iommu_groups/32/devices/0000:11:00.0
$ find /sys/kernel/iommu_groups/32 -type l
/sys/kernel/iommu_groups/32/devices/0000:11:00.0

```

So three of them were isolated in their IOMMU groups, but one was not.

After plugging the ezcoo hub into a random USB port,
I checked which USB bus it was connected to:

```sh
$ lsusb
Bus 008 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 007 Device 004: ID 046d:c52b Logitech, Inc. Unifying Receiver
Bus 007 Device 003: ID 1a40:0101 Terminus Technology Inc. Hub
Bus 007 Device 002: ID 05e3:0608 Genesys Logic, Inc. Hub
Bus 007 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 006 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 005 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 004 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 001 Device 003: ID 0bda:0852 Realtek Semiconductor Corp. Bluetooth Radio
Bus 001 Device 002: ID 048d:5702 Integrated Technology Express, Inc. RGB LED Controller
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```

The USB bus was 007, based on looking for the `Logitech, Inc. Unifying Receiver`
since I had plugged in the dongle for a Logitech Bluetooth keyboard.

Since bus 007 corresponded to PCIe device ID `0000:11:00.0',
I passed this device into the VM using the Proxmox web UI.

This caused the Proxmox host to crash when the VM booted.
Morever I had set this VM to start on boot.
After rebooting, Proxmox would dutifully start the VM and crash before I had any chance to undo what I'd done.
Well, shit.

Disabling virtualization in the BIOS looked like it would let me escape this cycle[^5].
I booted into the BIOS config by mashing `esc` to get to the GRUB menu and then entering the command `fwsetup`.
I disabled virtualization:

> Tweaker > Advanced CPU Settings > SVM Mode > Disabled

This allowed me to boot Proxmox without booting the problematic VM.
I disabled start on boot for the VM and removed the USB device from its passed hardware.

Lastly I entered the BIOS again and re-enabled virtualization.

Both Proxmox and the VM could boot as normal again,
but I still didn't have any USB ports passed through now.

To try and understand what happened, I took a closer look at the USB buses:

```sh
$ lsusb -tv
/:  Bus 08.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/0p, 5000M
    ID 1d6b:0003 Linux Foundation 3.0 root hub
/:  Bus 07.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/1p, 480M
    ID 1d6b:0002 Linux Foundation 2.0 root hub
    |__ Port 1: Dev 2, If 0, Class=Hub, Driver=hub/4p, 480M
        ID 05e3:0608 Genesys Logic, Inc. Hub
/:  Bus 06.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/2p, 10000M
    ID 1d6b:0003 Linux Foundation 3.0 root hub
/:  Bus 05.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/2p, 480M
    ID 1d6b:0002 Linux Foundation 2.0 root hub
/:  Bus 04.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/2p, 10000M
    ID 1d6b:0003 Linux Foundation 3.0 root hub
/:  Bus 03.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/2p, 480M
    ID 1d6b:0002 Linux Foundation 2.0 root hub
/:  Bus 02.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/5p, 20000M/x2
    ID 1d6b:0003 Linux Foundation 3.0 root hub
/:  Bus 01.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/12p, 480M
    ID 1d6b:0002 Linux Foundation 2.0 root hub
    |__ Port 6: Dev 2, If 0, Class=Human Interface Device, Driver=usbhid, 12M
        ID 048d:5702 Integrated Technology Express, Inc. RGB LED Controller
    |__ Port 9: Dev 3, If 0, Class=Wireless, Driver=btusb, 12M
        ID 0bda:0852 Realtek Semiconductor Corp. 
    |__ Port 9: Dev 3, If 1, Class=Wireless, Driver=btusb, 12M
        ID 0bda:0852 Realtek Semiconductor Corp.
```

Note, I had unplugged the ezcoo at this point so it's not listed.

It looks like something was using bus 007, but I didn't know what it is.
Nor did I have to find out, as buses 003/004 and buses 005/006 were also alone in their IOMMU groups
and didn't appear to have anything connected.

After plugging the ezcoo into a few more ports at random, I found one belong to bus 005.
Side note, most of the USB ports on the back panel belong to bus 007. 

Passing through the PCIe device associated with USB bus 005 worked without issue.

[^1]: https://www.baeldung.com/linux/check-for-usb-devices
[^2]: https://forums.unraid.net/topic/35112-guide-passthrough-entire-pci-usb-controller/
[^3]: https://forum.proxmox.com/threads/usb-controller-passthrough-proxmox-crash-connection-error.123044/
[^4]: https://forum.proxmox.com/threads/pcie-passthrough-with-more-than-one-nic-dont-work.89853/
[^5]: https://forum.proxmox.com/threads/is-there-a-way-to-disable-the-automatic-start-of-vms-before-proxmox-boots.83636/
