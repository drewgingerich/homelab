# 2. Use selected hardware

Date: 2023-12-18

## Status

Accepted

## Context

I am looking for parts that allow me to play modern games at 1440p and good settings.
I want parts from reliable vendors.
I otherwise want parts that are inexpensive.

I am not too particular about aesthetics and I prefer no LEDs.

I am shopping during Black Friday and Cyber Monday.

### GPU

I don't need ray tracing.

A Radeon 6700 XT seems to hit the balance of power and price I'm looking for.

A cowork is offering to sell me their used RTX 3070.

### CPU

I'm looking for a CPU that is powerful enough not to bottleneck the GPU.

I also want a CPU that uses a socket that will be around for a while
and give me an opportunity to upgrade after 4-6 years without replacing the motherboard.
Intel sockets have changed every 2-3 years
The AM4 socket lasted 5 years and the AM5 socket just came out and will likely be around for 5 more.

I may want a few extra cores for using Proxmox and running games inside a virtual machine.

The Ryzen 7600 or 7600X seems like a good fit.

There are no Black Friday sales for the 7600 or 7600X.
There is a sale for the 7700X.

### Motherboard

I'm looking for a motherboard that supports the CPU.

I prefer an ATX form factor because they are easier to work with,
but I could use a micro-ATX board too.

I want the board to have a USB 3.2 Gen 2x2 port, an M.2 slot,
and at least one extra PCIe slot in case I want to add a 10G network interface.

### Memory

I want 32 Gb of memory as this seems like a good entry-level amount these days.
I want 2 x 16Gb sticks to make use of dual channel memory for improved performance.

I want memory that works well with the CPU.

I want memory that is fast,
but I don't need the fastest out there.

### Storage

I don't need high uptime and will be backing up my data,
so I don't need redundant storage.
I can use a single drive.

I want 2 Tb of storage, as that seems like a good entrypoint
for giving myself a comfortable amount of space.
Extra space will be welcome if I ever decide to run more than one VM.

I want a decently fast SSD.
I want to use an M.2 form factor because they seem space efficient and nice to work with.

The Western Digital Black SN850X seems like a good fit.

There are no Black Friday sales for the SN850X.
There is a sale for the SK Hynix Platinum P41.

### Power Supply

I want a power supply that covers the power draw of the system,
plus a headroom of around 200 watts to cover spikey power usage and potential future additions.
I want it to be 80 Plus Gold certified or above,
mostly as an indirect measure of quality.

### CPU Cooler

I want a CPU cooler that effectively cools the CPU.

### Case

I want a rack-mounted case that fits my components.
I prefer a 4U case because I have the space, it will be easier to work in,
and it will fit larger fans for more quiet operation.

Rack-mounted cases designed for gaming PCs do not appear to be common.
I am willing to spend a price premium for a case that is designed for this
type of system because it will make me feel good.

## Decision

Buy and use the following parts.

| Part Name                                                               | Type         | Cost ($) |
| ----------------------------------------------------------------------- | ------------ | -------- |
| Zotac GAMING Trinity OC GeForce RTX 3070 Ti 8 GB                        | GPU          | 400.00   |
| AMD Ryzen 7 7700X 4.5 GHz 8-Core                                        | CPU          | 279.98   |
| Gigabyte B650 GAMING X AX ATX AM5                                       | Motherboard  | 159.99   |
| G.Skill Flare X5 32 GB (2 x 16 GB) DDR5-6000 CL30                       | Memory       | 93.99    |
| SK Hynix Platinum P41 2 TB M.2-2280 PCIe 4.0 X4 NVME SSD                | Storage      | 114.99   |
| Thermalright Peerless Assassin 120 SE                                   | CPU Cooler   | 40.89    |
| SeaSonic FOCUS Plus 750 Gold 750 W 80+ Gold Certified Fully Modular ATX | Power Supply | 95.00    |
| CX4150a Short Depth 4U                                                  | Case         | 334.00   |
|                                                                         |              | 1518.84  |

## Consequences

I'm out $1500.

I will have a computer that will allow me to play modern games at 1440p and high settings.

The extra cores on the CPU will help ensure there are enough resources to run VMs.

## References

- [The gaming PC I would build if I wasn't a privileged YouTuber](https://www.youtube.com/watch?v=Ctku3kDsXFQ)
