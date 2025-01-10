# Get a rack-mounted chasis

## Goal

Now that I [have a server rack](/docs/decisions/231006-get-a-server-rack.md),
I want a rack-mounted case for my media server.

I am looking for a case that:

- Fits an ATX mainboard
- Fits an ATX power supply
- Has at least 8 external 3.5" drive bays
- Supports hot-swappable drives
- Fits 120 mm fans
- SAS?

I am not looking for:

- Redundant PSUs

## Options

- https://www.sliger.com/products/rackmount/storage/cx3701/
- https://www.sliger.com/products/rackmount/storage/cx3702/
- https://www.sliger.com/products/rackmount/storage/cx4712/
- https://www.silverstonetek.com/en/product/info/server-nas/RM41-H08/
- https://www.rosewill.com/rosewill-rsv-l4412u-black/p/9SIA072GJ92847?seoLink=server-components&seoName=Server%20Chassis
- http://www.istarusa.com/en/istarusa/products.php?model=D2-400L-M10SA
- https://www.chenbro.com/en-global/products/RackmountChassis/4U_Chassis/RM42200

## Decision

Buy a Sliger CX4712 chasis

## Side effects

## Exploration

My media server doesn't have a rack-mounted case.
I have a server rack now, so I would prefer to house it in a rack-mounted case.

Since a new chasis is a long-term investment and I have space,
I want one that can accomodate a full-sized ATX mainboard for flexibility,
even though the corrent system uses a micro-ATX mainboard.
Since ATX chasis can accomodate a micro-ATX mainboard,
I don't currently have to buy a new mainboard.

For the same reason, I want a chasis that fits an ATX power supply.
The system uses an ATX power supply already,
so again I don't have to buy a new component.


I'd like external drive bays that support hot-swappable drives.
Since I'm using ZFS and it supports hot-swapping drives,
I don't want to have to open up the whole case to do so.

I don't think I'll ever need more than 3 mirrored pairs of drives and a hot-spare,
totaling 7 drives,
so I'd like 7 or just a few more drive bays.
I'm currently only running 2 x 4 TB mirrored pairs,
this will give me a ton of potential to expand the storage capacity,
especially with larger drives.

While my server rack is in the basement and sound is not the biggest issue,
I'd still prefer low noise.
To this end, I want a case that supports 120 mm fans, or even 140 mm.

## References

https://serverfault.com/questions/746191/how-do-i-connect-a-disk-array
