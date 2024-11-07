# DRAFT: Get a UPS

## Problem

I want my servers to be protected from power anomalies.

## Decision

Get a line-interactive, rack-mounted UPS.

## Consequences

My computers will be be protected from power quality deviations in the input power.
They will not be protected from deviations in voltage frequency or waveform.

I will spend several hundred dollars.

I will need to periodically replace the UPS batteries,
and dispose of the old batteries.

My server rack will start to look like I know what I'm doing.

## Context

I have two servers in my rack.
I want to make sure they are protected from power quality deviations,
such as power surges and power loss.

### Power quality deviations

The electrical power supplied by an electrical grid follows specifications, with details depending on location.
In North America, where I live, the specification is a pure sine wave with a 120 V amplitude and 60 hz frequency.

The actual electrical power provided by the grid can deviate from this specification.
Common deviation include:

1. Power loss or blackout: voltage drops to zero.
   Can be cuased by many things, generally equipment failure.
   Common cause is damage to the electrical grid from storms.
2. Voltage sag: a temporary dip in voltage (one half-cycle to one minute).
   Can be caused by the start of heavy loads---e.g. a washing machine---on the same circuit.
3. Undervoltage or brownout: Voltage that is chronically low (longer than one minute).
4. Power surge or spike: transient overvoltage (one half-cycle or less).
   Often very large.
   Commonly cuased by lightning strikes or equipment failure.
5. Overvoltage: chronically high voltage
6. Frequency variation: frequuncy above or below 60 hz.
7. Line noise: very high frequency noise added to the sine wave due to electronmagnetic interference (EMI).
8. Switching transient: transient deviations in the wave form due to a sudden switch in the circuit.
   Caused by e.g. connecting/disconnecting a mechanical load or opening/closing a breaker.
   These create a sudden disturbance from the circuit's steady state, and transients as it returns.
   Like the waves caused by jumping into a boat.
9. Harmonic distortion: the presence of other waves in the current due to devices with nonlinear loads.
   These other waves interfere with the main sine wave, and can reduce the peak voltage.
   This has the effect of producing an undervoltage.

Poor power quality can cause problems because devices are design for the specification.
Too high of a current can damage electronics by overheating them,
while too low of a current can cause data corruption when electronic operations fail.
Most electronics are designed to handle common types and magnitudes of power quality deviations, though.
If they weren't, then customers would be complaining all the time.

A computer power supply unit (PSU) filters out many moderate power quality deviations.
The power supply converts AC wall power to the DC power used by the electical components,
and part of this process involves filtering the DC signal using large capacitors.
This filtering has a side effect of also mitigating many deviations in the input AC power,
and PSUs also generally have some amount of surge protection built in.
They can't handle deviations that affect the RMS power of the input too much (e.g. a brownout or blackout), or large deviations.

[How PC Power Supplies Work](https://web.archive.org/web/20230926081417/https://computer.howstuffworks.com/power-supply.htm)
[How Power Supplies Work - Turbo Nerd Edition](https://www.youtube.com/watch?v=i9ZnaA8DZDs)
[Understanding AC/DC Power Supplies](https://web.archive.org/web/20230524071639/https://www.monolithicpower.com/en/ac-dc-power-supply-basics)
[What ill effects do harmonics created by the computer power supplies have on themselves?](https://web.archive.org/web/20230131204129/https://powerquality.blog/2021/11/22/what-ill-effects-do-harmonics-created-by-the-computer-power-supplies-have-on-themselves/)
https://www.youtube.com/watch?v=fRhQ9ffecHA

An uniterruptable power supply (UPS) is a piece of equipment that mitigates more extreme deviations by switching to battery power when detected,
sheltering downstream electronics.

UPSs have three common designs:

- Offline: mechanically switches load to battery power when input voltage deviates past a threshold.
- Line-interactive: similar to an offline UPS, with additional voltage regulation to compensate for small voltage deviations without needing to switch to batter power.
- Online: completely separates the load from mains power, always running load on battery power.
  Charges battery of mains power at the same time. Sidesteps power quality issues with the mains power, always providing
  high-quality power to the load.

https://en.wikipedia.org/wiki/Rectifier
https://superuser.com/questions/912679/when-do-i-need-a-pure-sine-wave-ups
[Uninterruptible power supply (Wikipedia)](https://web.archive.org/web/20231210194131/https://en.wikipedia.org/wiki/Uninterruptible_power_supply)
[Line-Interactive UPS vs Online UPS (Power Sonic)](https://web.archive.org/web/20240116134652/https://www.power-sonic.com/wp-content/uploads/2021/02/Line-Interactive-Vs-Online-UPS.pdf)
[Comparison of UPS Topologies: Line-interactive vs Online vs Offline](https://web.archive.org/web/20231204144929/https://community.fs.com/article/line-interactive-vs-online-vs-offline-ups.html)


This protects downstream electronics from under and overvoltage, including blackouts and power surges.
It doesn't do anything about frequency or waveform deviations.
The mechanical switching can produce a transient.

A line-interactive UPS is the same as an offline UPS,
and additionally compensates for smaller voltage deviations without needing to switch to battery power.
It doesn't do anything about frequency or waveform deviations.
Adding this voltage compensation is cheap, so most rack-mount UPSs are line-interactive rather than offline.
The voltage compensator reduces the switching transient.

An online UPS completely separates the load from mains power,
always running off battery while mains power simultaneously charges the battery.
The output power has no deviations because of this complete separation (assuming the battery produces ideal power).
Because power is always provided from the batter, online UPSs don't produce a switching transient.
Online UPSs are much more expensive the offline or line-interactive.





Thoroughly understanding the possible causes and effects of deviations is involved and beyond me.
The best I can think of doing is to measure the power at the outlet to see if there are any existing deviations.
The cost of an oscilliscope or mutilmeter capable of collecting this data are at least several hundred dollars,
which is more than I want to spend.
I'm also wary of measuring mains power as the voltage is high enough to be dangerous and I'm inexperienced.
I will not measure the power quality, and trust that it's generally good.

I do have two known concerns.
One is that I get occasional outages during storms, and may get a power surge.
The second is that my servers are on the same circuit as the washing machine,
which may cause voltage deviations when it starts and stops.



in its waveform, amplitude, and frequency.
Nine common deviations are:

1. Power loss or blackout: voltage drops to zero.
   Can be cuased by many things, generally equipment failure.
   Common cause is damage to the electrical grid from storms.
2. Voltage sag: a temporary dip in voltage (one half-cycle to one minute).
   Can be caused by the start of heavy loads---e.g. a washing machine---on the same circuit.
3. Undervoltage or brownout: Voltage that is chronically low (longer than one minute).
4. Power surge or spike: transient overvoltage (one half-cycle or less).
   Often very large.
   Commonly cuased by lightning strikes or equipment failure.
5. Overvoltage: chronically high voltage
6. Frequency variation: frequuncy above or below 60 hz.
7. Line noise: very high frequency noise added to the sine wave due to electronmagnetic interference (EMI).
8. Switching transient: transient deviations in the wave form due to a sudden switch in the circuit.
   Caused by e.g. connecting/disconnecting a mechanical load or opening/closing a breaker.
   These create a sudden disturbance from the circuit's steady state, and transients as it returns.
   Like the waves caused by jumping into a boat.
9. Harmonic distortion: the presence of other waves in the current due to devices with nonlinear loads.
   These other waves interfere with the main sine wave, and can reduce the peak voltage.
   This has the effect of producing an undervoltage.

### Power quality and electronics

Electronics are designed to work with this standard.
When electronics receive power that deviates from this standard, they can malfunction or be damaged.
Exactly how electronics interact with various deviations widely varies based on the particular electronics.

Low voltage can cause electronic components to stop working.

Power loss can result in data corruption because it can interrupt write operations.

Every computer has a power supply that converts the AC power from the wall to the DC powers used by the various components in the computer.

The output of the AC to DC conversion process is filtered using large capacitors to smooth out the voltage ripple produced by the conversion.
This filtering can also help correct for deviations in the input AC power.
These large filtering capacitors also smooth out transient voltage deviations.

PSUs generally have some amount of surge protection built in.

PSUs cannot correct for under voltage, including power outages.

https://www.teamwavelength.com/power-supply-basics/

### My power quality

I live in North America.
The power here is ideally a pure sine wave with a 120 V amplitude and 60 hz frequency.
The power grid in my area probably provides power that closely matches this ideal.

We get occasional power outages and voltage fluctuations during storms.

My servers are connected to a surge protector, which is connected to a wall outlet.

My servers are running on the same circuit as the fan for the house's central air system,
and the fan turning on and off might cause voltage fluctuations.
There may be other things on the circuit that I don't know about as well, it's an old house and a rental.

I used a digital multimeter to observe the voltage as the fans turned on and off.

Tools to measure waveform abberations such as harmonics and transients cost hundreds or thousands of dollars.
This is more than I'm willing to spend, considering it's probably fine.

### Uniterruptable Power Supply (UPS)

An uniterruptable power supply is a piece of equipment that switched over to a battery during a power outage,
preventing any connected electronics from powering down.
UPSs can also correct for a variety of other power anomalies, depending on the UPS.

#### Types

There are three common types of UPS: offline (aka standby), line-interactive, and online (aka double-conversion)

An offline UPS mechanically switches its load from mains to battery power when input voltage deviates past a threshold.
This protects downstream electronics from under and overvoltage, including blackouts and power surges.
It doesn't do anything about frequency or waveform deviations.
The mechanical switching can produce a transient.

A line-interactive UPS is the same as an offline UPS,
and additionally compensates for smaller voltage deviations without needing to switch to battery power.
It doesn't do anything about frequency or waveform deviations.
Adding this voltage compensation is cheap, so most rack-mount UPSs are line-interactive rather than offline.
The voltage compensator reduces the switching transient.

An online UPS completely separates the load from mains power,
always running off battery while mains power simultaneously charges the battery.
The output power has no deviations because of this complete separation (assuming the battery produces ideal power).
Because power is always provided from the batter, online UPSs don't produce a switching transient.
Online UPSs are much more expensive the offline or line-interactive.

#### Automation

Many UPS options have the ability to send signals via the network, USB, or Serial cables.
This can be used to trigger shutoffs when the UPSs battery power gets low.

#### Batteries

Lead-acid is the current standard,
balancing power with cost.

Lithium-ion is another option,
although they are very expensive.

Lithium iron phosphate (LiFeP4) batteries are third option,
although even more expensive.

Some UPSs have hot-swappable batteries.
This makes battery replacement much easier.

#### Sizing a UPS

Aim for 50-70% load.

#### Where to buy

There are a few sellers for refurbished UPSs with new batteries.
From what I've seen, these are trusted and much cheaper than buying new.

## References

- https://www.youtube.com/watch?v=yDX_1PWUWdw

- [How PC Power Supplies Work](https://web.archive.org/web/20230926081417/https://computer.howstuffworks.com/power-supply.htm)
- [How Power Supplies Work - Turbo Nerd Edition](https://www.youtube.com/watch?v=i9ZnaA8DZDs)
- [Understanding AC/DC Power Supplies](https://web.archive.org/web/20230524071639/https://www.monolithicpower.com/en/ac-dc-power-supply-basics)
- [What ill effects do harmonics created by the computer power supplies have on themselves?](https://web.archive.org/web/20230131204129/https://powerquality.blog/2021/11/22/what-ill-effects-do-harmonics-created-by-the-computer-power-supplies-have-on-themselves/)

- https://web.archive.org/web/20240107153149/https://tripplite.eaton.com/products/pdu-installation

- [Electric power quality (Wikipedia)](https://web.archive.org/web/20231128124149/https://en.wikipedia.org/wiki/Electric_power_quality)
- https://web.archive.org/web/20211005122635/https://www.eaton.com/us/en-us/products/backup-power-ups-surge-it-power-distribution/backup-power-ups/9-common-power-problems.html
- https://web.archive.org/web/20231003101933/https://www.qpsolutions.net/power-anomalies/9-power-anomalies-that-every-facility-should-fear/
- [Voltage sag (Wikipedia)](https://en.wikipedia.org/wiki/Voltage_sag)
- [Brownout (Wikipedia)](https://en.wikipedia.org/wiki/Brownout_(electricity))
- [Overvoltage (Wikipedia)](https://en.wikipedia.org/wiki/Overvoltage)
- [Transient response (Wikipedia)](https://en.wikipedia.org/wiki/Transient_response)

- [Uninterruptible power supply (Wikipedia)](https://web.archive.org/web/20231210194131/https://en.wikipedia.org/wiki/Uninterruptible_power_supply)
- [Line-Interactive UPS vs Online UPS (Power Sonic)](https://web.archive.org/web/20240116134652/https://www.power-sonic.com/wp-content/uploads/2021/02/Line-Interactive-Vs-Online-UPS.pdf)
- [Comparison of UPS Topologies: Line-interactive vs Online vs Offline](https://web.archive.org/web/20231204144929/https://community.fs.com/article/line-interactive-vs-online-vs-offline-ups.html)

- [Different Types Of UPS Batteries](https://web.archive.org/web/20230310044001/https://www.riello-ups.com/questions/60-different-types-of-ups-batteries)

- [Choosing a UPS](https://www.youtube.com/watch?v=ovZAbCqh_A0)

- https://www.refurbups.com/
- https://excessups.com/
