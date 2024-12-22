# Create an Ubuntu image template

## Plan

Proxmox can mark VM images as [templates](https://pve.proxmox.com/wiki/VM_Templates_and_Clones).
Templates act as a checkpoint in the image creation and provisioning process.
Templates are not run directly but are instead cloned to produce runnable images.

Having a template with a fully provisioned system means that I can reproducibly
create images.

The creation of the template itself will not be reproducible since I'll be doing it manually.
Backing up the template will be essential for peace of mind.

I plan to install Ubunutu and save the result as a template,
so that I don't have to do install Ubunut each time I want to make a new image.

## Downloading the Ubuntu ISO

I went to the [Ubuntu releases page](https://releases.ubuntu.com/) and find the latest Ubuntu desktop release: `https://releases.ubuntu.com/22.04.3/ubuntu-22.04.3-desktop-amd64.iso`

In the Proxmox web UI, I navigated to my node's local storage, selected the ISO Images side tab and clicked the `Download from URL` button. I entered the URL of the ISO download above. In the advanced options I additional selected the SHA256 checksum and entered the value from the `SHA256SUMS` file that was also in the Ubuntu releases page. Proxmox downloaded the ISO and verified the checksum.

## Creating an Ubunutu VM

To begin the VM creation process, I clicked the `Create VM` button in the Proxmox web UI.
I named the VM after the OS and date to keep track of what and when.
I selected the ISO I downloaded.

I left every value as the default except for selecting 6 CPU cores and 10,000 MiB of memory.

Once installation was complete, I shot down the VM.
In the Proxmox web UI, I selected the image and then selected `Convert to template` from the `more` menu in the upper right.
Proxmox worked for a moment, and the image was marked as a template.
