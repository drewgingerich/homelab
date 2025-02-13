# Setting fan curve

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

I have broken my adventures off into [another note](media-server/docs/notes/250212A-IPMI-password-troubles.md),
but I was eventually able to get back in.

