# Troubleshooting fan speeds

After moving to the new case, I noticed that the fans would spin up a lot every few seconds.

In the new case the fans are plugged into 4-pin mainboard fan headers,
while in old case the fans were plugged in an in-case fan controller with 3-pin connections.

My guess is that the fan curve set in the BIOS is spinning up the fans for even small CPU temperature increases.

The CPU fan may have been spinning up and down in the old case without me noticing because it's very quiet.

The [mainboard manual](https://www.supermicro.com/manuals/motherboard/C236/MNL-1785.pdf) states:

> Fan speed control is available for 4-pin fans only by Thermal Management via the IPMI 2.0 interface.

So looking in the [IPMI](https://www.supermicro.com/manuals/other/IPMI_Users_Guide.pdf) web UI seems like a good bet.

I don't normally have the BMC ethernet port connected, so I do that.

I look at my router's device table to find the IP address and navigate there in my browser.

The username is `ADMIN` and the password is also `ADMIN`, which are the defaults.

The first thing I do is update the password.
And then I try re-logging in and I can't!

I have broken my IPMI auth adventures out into [another note](media-server/docs/notes/250212A-IPMI-password-troubles.md),
but I was eventually able to get back in.
TL;DR my new password got truncated to 19 characters.

The IPMI web UI lets me choose between four fan modes: Optimized, Standard, HeavyIO, and Full.

https://forums.servethehome.com/index.php?resources/supermicro-x9-x10-x11-fan-speed-control.20/

Setting the mode to Optimized (the lowest setting) didn't make a noticeable difference.
Setting the mode to Full did run the fans at 100%.
My takeaway is that the fan modes do work, but there seems to be something else off.

After looking around more, I learned that IPMI is a specification
that allows for much more control over fan speed than the four modes presented by the web UI.
The web UI is only a client providing a simplified window into IPMI's full capabilities.

I also learned that the constant spinning up and down is likely caused by
IPMI default fan speed thresholds that don't match the actual specs of the fans I'm using.
In particular if the lower threshold is higher than the fans' minimum speed,
every time the fans spin down they'll breach the threshold
and the IPMI controller will try to recover by spinning them up to 100% for a few seconds.
This results in the cycle of fans spinning up and down that I observe.

https://www.truenas.com/community/threads/supermicro-x11-fan-speeds.69712/

This is supported by the sensor measurements in the IPMI web UI:
the fan speeds drop to 500 RPM, but 500 is the low critical fan speed threshold.

https://www.youtube.com/watch?v=LDY5RcNIZ_M&t=9s

The fix should be to set the thresholds based on the specs of the fans I'm using.

https://www.reddit.com/r/unRAID/comments/ppuk4w/pwm_fan_control_fans_running_at_100_on_supermicro/
https://www.truenas.com/community/resources/how-to-change-ipmi-sensor-thresholds-using-ipmitool.35/

The Noctua NF-A12x25 PWM case fans I'm using have a min speed of 450 RPM.
This should be the low non-critical threshold, but there is also an error of +-20%.
Taking the minimum of the error range nets 360 RPM.
It seems like IPMI can only set fan speed thresholds at increments of 100 RPM,
so a final rounding down brings this to 300 RPM.

https://noctua.at/en/nf-a12x25-pwm/specification
https://forums.truenas.com/t/supermicro-fan-control/1518/4

As for the low critical and low non-recoverable thresholds,
the advice I've seen is to set the low critical threshold 100 RPM lower
and the low non-recoverable threshold 200 RPM lower than the low non-critical threshold.
This brings the desired thresholds to 300, 200, 100 RPM for the
low non-critical, critical, and non-recoverable thresholds.

To set these thresholds, it looks like I'll need to use one of a few CLI tool:

- [impicfg](https://www.supermicro.com/en/solutions/management-software/ipmi-utilities) is a proprietary tool from Supermicro.
- [ipmitool](https://github.com/ipmitool/ipmitool) seems to be the industry standard, being included in FreeBSD and TrueNAS,
  but the GitHub repo has been archived due to sanctions related to Russia's war on Ukraine.
- [ipmiutil](https://github.com/arcress0/ipmiutil)
- [freeipmi](https://www.gnu.org/software/freeipmi/)

https://github.com/mrstux/hybrid_fan_control
