# Get a rack-mounted case

## Goal

Get a rack-mounted case that fulfills the current and short-term needs of my media server. 

## Options

- [Sliger CX3702](https://www.sliger.com/products/rackmount/storage/cx3702/)
- [Sliger CX4712](https://www.sliger.com/products/rackmount/storage/cx4712/)
- [SilverStone RM43-320-RS](https://www.silverstonetek.com/en/product/info/server-nas/RM43-320-RS/)
- [Rosewill L4412U](https://www.rosewill.com/rosewill-rsv-l4412u-black/p/9SIA072GJ92847?seoLink=server-components&seoName=Server%20Chassis)
- [iStarUSA M-4160-ATX](http://www.istarusa.com/en/istarusa/products.php?model=M-4160-ATX)

## Decision

Buy a Sliger CX4712 case.

## Side effects

I will have a flexible, medium-density, rack-mounted storage server case.

## Exploration

Now that I [have a server rack](/docs/decisions/231006-get-a-server-rack.md),
I want a rack-mounted case for my media server.

I want a case that fits my current components.
I am additionally interested in a 4U case that fits an ATX mainboard and power supply so
that I have lots of room to work in and flexibility on future components.
I have plenty of space in the server rack, so efficient use of rack space is not a concern.

I would like the case to fit 120mm fans to minimize noise,
since the server rack is in my office.

My server currently has 4 x 4 TB HDDs.
I would like to have a comfortable amount of room to expand the storage.
While I haven't made any decisions, I am interested in:

- 2 x HDD mirror for more media storage
- 2 x SSD mirror for application and database data
- 1 x HDD hot spare for the HDD mirrors
- 1 x HDD for a backup pool, just in case

A case with 8 to 16 3.5" drive bays seems like a comfortable range of sizes.

I am also interested in hot-swap drive bays so that
I can manage storage devices without needing to open up the case.

Cases that support so many drives generally come with a SAS/SATA backplane.
These backplanes appear to mostly have bandwidths of 6 or 12 GB/s.
HDDs have bandwidths in the low hundreds of MB/s,
so a slower 6 GB/s backplane should be plenty.

It will also be helpful to call out that I am not looking for cases supporting redundant PSUs.

## References

https://serverfault.com/questions/746191/how-do-i-connect-a-disk-array
