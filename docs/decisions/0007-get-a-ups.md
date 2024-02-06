# 7. Get a UPS

Date: 2024-02-05

## Status

Pending

## Context

My servers are running on the same circuit as the fan for the house's central air system.
We get occasional brief power outages during storms.

I live in North America.
The standard power supply here is a pure sine wave with a 120 V amplitude and 60 hz frequency.

Electronics are designed to work with this standard.
When electronics receive power that deviates from this standard, they can malfunction or be damaged.

Electrical power can deviate in its waveform, voltage, and/or frequency.

### Effects of power quality deviations

Low voltage can cause electronic components to stop working.

### Common power quality deviations

9 types of deviation from standard power are considered common concerns.

Power loss, also called a blackout, is when voltage goes to zero.
This is generally caused by equipment failure somewhere in the power grid.
Root causes are wide-ranging, such as lightning strikes, human error, or a tree falling on a power line.
Power loss can result in data corruption because it can interrupt write operations.
Power loss by itself is unlikely to damage electronics, but can be accompanied by other power deviations.

A voltage sag is when voltage dips temporarily, from one-half cycle to one minute.
Can be caused by the start of heavy loads, such as a washing machine.

Undervoltage (a brown out) is when voltage is chronically low. a chronic low voltage
over 1 minute is an undervoltage (brownout)

A power spike or surge is a transient overvoltage, that half a cycle long.
They are often very large.
Caused by things such as lightning strikes.

Overvoltage is a chronically high voltage
longer term overvoltage is just known as overvoltage

Frequency variation is when the power is not at 60 hz.

Line noise is very high frequency noise added to the sine wave due to electronmagnetic interference (EMI).

Harmonic distortion is the presence of other waves in the current due to devices with nonlinear loads.
These other waves interfere with the main sine wave, and can reduce the peak voltage.
This has the effect of producing an undervoltage.

### Power Supply Units (PSU) and power quality

Every computer has a power supply that converts the AC power from the wall to the DC powers used by the various components in the computer.

The output of the AC to DC conversion process is filtered using large capacitors to smooth out the voltage ripple produced by the conversion.
This filtering can also help correct for deviations in the input AC power.
These large filtering capacitors also smooth out transient voltage deviations.

PSUs generally have some amount of surge protection built in.

PSUs cannot correct for under voltage, including power outages.

### Uniterruptable Power Supply (UPS) and power quality

There are three common types of UPS: offline (aka standby), line-interactive, and online (aka double-conversion)

An offline UPS mechanically switches its load from mains to battery power when input voltage deviates past a threshold.
This protects downstream electronics from under and overvoltage,
including blackouts and power surges,
but doesn't do anything about frequency or waveform deviations.

A line-interactive UPS is the same as an offline UPS,
and additionally compensates for smaller voltage deviations without needing to switch to battery power.
Adding this voltage compensation is cheap,
and most rack-mount UPSs will be line-interactive rather than offline.

An online completely separates the load from mains power,
always running off battery while mains power simultaneously charges the battery.
The output power has no deviations because of this complete separation (assuming the battery produces ideal power).
Online UPSs are much mor expensive the offline or line-interactive.

### UPS battery types

## Decision

Get a line-interactive UPS.

The change that we're proposing or have agreed to implement.

## Consequences

What becomes easier or more difficult to do and any risks introduced by the change that will need to be mitigated.

## References

- https://www.youtube.com/watch?v=yDX_1PWUWdw

- [How PC Power Supplies Work](https://web.archive.org/web/20230926081417/https://computer.howstuffworks.com/power-supply.htm)
- [How Power Supplies Work - Turbo Nerd Edition](https://www.youtube.com/watch?v=i9ZnaA8DZDs)
- [What ill effects do harmonics created by the computer power supplies have on themselves?](https://web.archive.org/web/20230131204129/https://powerquality.blog/2021/11/22/what-ill-effects-do-harmonics-created-by-the-computer-power-supplies-have-on-themselves/)

- https://web.archive.org/web/20240107153149/https://tripplite.eaton.com/products/pdu-installation

- [Electric power quality (Wikipedia)](https://web.archive.org/web/20231128124149/https://en.wikipedia.org/wiki/Electric_power_quality)
- https://web.archive.org/web/20211005122635/https://www.eaton.com/us/en-us/products/backup-power-ups-surge-it-power-distribution/backup-power-ups/9-common-power-problems.html
- https://web.archive.org/web/20231003101933/https://www.qpsolutions.net/power-anomalies/9-power-anomalies-that-every-facility-should-fear/

- [Uninterruptible power supply (Wikipedia)](https://web.archive.org/web/20231210194131/https://en.wikipedia.org/wiki/Uninterruptible_power_supply)
- [Line-Interactive UPS vs Online UPS (Power Sonic)](https://web.archive.org/web/20240116134652/https://www.power-sonic.com/wp-content/uploads/2021/02/Line-Interactive-Vs-Online-UPS.pdf)
- [Comparison of UPS Topologies: Line-interactive vs Online vs Offline](https://web.archive.org/web/20231204144929/https://community.fs.com/article/line-interactive-vs-online-vs-offline-ups.html)

- [Different Types Of UPS Batteries](https://web.archive.org/web/20230310044001/https://www.riello-ups.com/questions/60-different-types-of-ups-batteries)

- https://www.refurbups.com/
- https://excessups.com/
