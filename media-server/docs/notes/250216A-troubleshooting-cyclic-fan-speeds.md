# Troubleshooting cyclic fan speeds

After moving to the new case, I noticed that the fans would spin up a lot every few seconds.

In the new case the fans are plugged into 4-pin mainboard fan headers,
while in old case the fans were plugged into an in-case fan controller with 3-pin connections.

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

The stock Intel CPU cooler I'm using is part number E97379-003.

The min speed is 1000 +/- 300 RPM, giving a low non-critical threshold of 700.

https://www.intel.com/content/www/us/en/products/sku/90729/intel-core-i36100-processor-3m-cache-3-70-ghz/specifications.html
https://www.intel.com/content/www/us/en/content-details/841156/e97379-foxconn-datasheet.html

To set these thresholds, it looks like I'll need to use one of a few CLI tool:

- [impicfg](https://www.supermicro.com/en/solutions/management-software/ipmi-utilities) is a proprietary tool from Supermicro.
- [ipmitool](https://github.com/ipmitool/ipmitool) seems to be the industry standard, being included in FreeBSD and TrueNAS,
  but the GitHub repo has been archived due to sanctions related to Russia's war on Ukraine.
- [ipmiutil](https://github.com/arcress0/ipmiutil)
- [freeipmi](https://www.gnu.org/software/freeipmi/)

https://www.gnu.org/software/freeipmi/freeipmi-faq.html#FreeIPMI-vs-OpenIPMI-vs-Ipmitool-vs-Ipmiutil
https://ipmiutil.sourceforge.net/docs/ipmisw-compare.htm

I decide to try `ipmiutil` first.
I install it directly on my media server,
since my laptop is macOS and there is not a macOS release.

```sh
$ sudo apt update
$ sudo apt install ipmiutil
```

I start by getting the fan numbers and current sensor thresholds:

```sh
$ sudo ipmiutil sensor -U ADMIN -Y -g fan -c
ipmiutil sensor version 3.18
Enter IPMI LAN Password:
*******************
-- BMC version 1.48, IPMI version 2.0
_ID_ SDR_Type_xx ET Own Typ S_Num   Sens_Description   Hex & Interp Reading
025f SDR Full 01 01 20 a 04 snum 41 FAN1             = 05 Crit-lo 500.00 RPM
        Entity ID 29.1 (Fan), Capab: arm=auto thr=write evts=state
        Volatile hi-unrec 25500.00 hi-crit 25400.00 hi-noncr 25300.00 lo-noncr 700.00 lo-crit 500.00 lo-unrec 300.00
        SdrThres hi-unrec 25500.00 hi-crit 25400.00 hi-noncr 25300.00 lo-noncr 700.00 lo-crit 500.00 lo-unrec 300.00
        nom 12800.00 nmax 17000.00 nmin 2000.00 smax 25500.00 smin 0.00
02a2 SDR Full 01 01 20 a 04 snum 42 FAN2             = 05 Crit-lo 500.00 RPM
        Entity ID 29.2 (Fan), Capab: arm=auto thr=write evts=state
        Volatile hi-unrec 25500.00 hi-crit 25400.00 hi-noncr 25300.00 lo-noncr 700.00 lo-crit 500.00 lo-unrec 300.00
        SdrThres hi-unrec 25500.00 hi-crit 25400.00 hi-noncr 25300.00 lo-noncr 700.00 lo-crit 500.00 lo-unrec 300.00
        nom 12800.00 nmax 17000.00 nmin 2000.00 smax 25500.00 smin 0.00
02e5 SDR Full 01 01 20 a 04 snum 43 FAN3             = 05 Crit-lo 500.00 RPM
        Entity ID 29.3 (Fan), Capab: arm=auto thr=write evts=state
        Volatile hi-unrec 25500.00 hi-crit 25400.00 hi-noncr 25300.00 lo-noncr 700.00 lo-crit 500.00 lo-unrec 300.00
        SdrThres hi-unrec 25500.00 hi-crit 25400.00 hi-noncr 25300.00 lo-noncr 700.00 lo-crit 500.00 lo-unrec 300.00
        nom 12800.00 nmax 17000.00 nmin 2000.00 smax 25500.00 smin 0.00
0328 SDR Full 01 01 20 a 04 snum 44 FAN4             = 00 Absent 0.00 na
        Entity ID 29.4 (Fan), Capab: arm=auto thr=write evts=state
        SdrThres hi-unrec 25500.00 hi-crit 25400.00 hi-noncr 25300.00 lo-noncr 700.00 lo-crit 500.00 lo-unrec 300.00
        nom 12800.00 nmax 17000.00 nmin 2000.00 smax 25500.00 smin 0.00
036b SDR Full 01 01 20 a 04 snum 45 FANA             = 1f OK 3100.00 RPM
        Entity ID 29.5 (Fan), Capab: arm=auto thr=write evts=state
        Volatile hi-unrec 25500.00 hi-crit 25400.00 hi-noncr 25300.00 lo-noncr 700.00 lo-crit 500.00 lo-unrec 300.00
        SdrThres hi-unrec 25500.00 hi-crit 25400.00 hi-noncr 25300.00 lo-noncr 700.00 lo-crit 500.00 lo-unrec 300.00
        nom 12800.00 nmax 17000.00 nmin 2000.00 smax 25500.00 smin 0.00
ipmiutil sensor, completed successfully
```

Next I set the sensor thresholds for each fan, one at a time.
For example:

```sh
sudo ipmiutil sensor -U ADMIN -Y -u 300:200:100:25300:25400:25500 -p -n 41
ipmiutil sensor version 3.18
Enter IPMI LAN Password:
*******************
sensor_num = 0x41
-- BMC version 1.48, IPMI version 2.0
...
GetThreshold[41]: 41 3f 07 05 03 fd fe ff
SetThreshold[41]: 41 3f 03 02 01 fd fe ff
SetSensorThreshold[41] to lo=03(300.000) hi=fd(25300.000), ret = 0
Saved thresholds for sensor 41
ipmiutil sensor, completed successfully
```

I decided not to change the thresholds of the CPU cooler (sensor ID 45, header FANA), 
since the default low non-critical threshold already matched the fan specs.

I also decided not to change the high thresholds.
I just want to get the fans working passably right now.

At this point the fans are running at 100% even with the new thresholds.
I reset the BMC to kick things:

```sh
$ sudo ipmiutil reset -U ADMIN -Y -k
ipmiutil reset ver 3.18
Enter IPMI LAN Password:
*******************
-- BMC version 1.48, IPMI version 2.0
Power State      = 00   (S0: working)
ipmiutil reset: cold reset BMC ...
ipmiutil reset: Cold_Reset to BMC ok
ipmiutil reset, completed successfully
```

The fans are now running nice a smooth!

In the IPMI web UI, I set the Fan Mode back to Standard.

