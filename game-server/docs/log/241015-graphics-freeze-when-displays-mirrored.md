A new problem appeared!
The graphics freeze a few seconds after starting a game through Steam.
The game and audio continued to run fine.

The most recent thing I did was connect the server to the TV.
Now that the server is connected to two displays,
Sunshine might be having an issue choosing the right display.

Looking at the Sunshine logs I see that Sunshine finds both displays:

```
[2024:09:11:21:00:16]: Info: -------- Start of KMS monitor list --------
[2024:09:11:21:00:16]: Info: Monitor 1 is DP-1: Telecom Technology Centre Co. Ltd. 23"
[2024:09:11:21:00:16]: Info: Monitor 0 is HDMI-1: Sony SONY TV XV
[2024:09:11:21:00:16]: Info: --------- End of KMS monitor list ---------
```

One possibility is that Sunshine is trying to use the TV as a monitor while the TV is off.
Sunshine uses monitor 0, which from the logs is the TV.

Updating the Sunshine config via the web UI to use monitor 1 didn't resolve the problem, though.

On a whim I tried turning off display mirroring and this did fix the problem.
I want display mirroring, though.

I looked at the Sunshine logs again and noticed a warning:

```
[2024:09:12:14:33:29]: Info: -------- Start of KMS monitor list --------
[2024:09:12:14:33:29]: Warning: Mismatch on expected Resolution compared to actual resolution: 0x0 vs 1920x1080
[2024:09:12:14:33:29]: Info: Monitor 0 is HDMI-1: Sony SONY TV XV
[2024:09:12:14:33:29]: Info: --------- End of KMS monitor list ---------
```

So it looks like something went wrong when it was fetching info about the Display Port dummy plug.

After a reboot it appears that Sunshine sees both monitors again:

```
[2024:09:12:14:43:19]: Info: -------- Start of KMS monitor list --------
[2024:09:12:14:43:19]: Info: Monitor 1 is DP-1: Telecom Technology Centre Co. Ltd. 23"
[2024:09:12:14:43:19]: Info: Monitor 0 is HDMI-1: Sony SONY TV XV
[2024:09:12:14:43:19]: Info: --------- End of KMS monitor list ---------
```

After a reboot, I checked to if Sunshine worked when set to either display: it did.

I was able to reproduce the problem with Sunshine set either display.

I noticed a separate issue wherein even after a fresh boot,
Moonlight stoped being able to connect after a while.

Taking a look at the Sunshine logs, I saw that Sunshine wasn't able to find a display:

```
[2024:09:12:16:12:20]: Fatal: Unable to find display or encoder during startup.
[2024:09:12:16:12:20]: Fatal: Please ensure your manually chosen GPU and monitor are connected and powered on.
```

I remembered I had configured the screen to blank after 5 minutes in an attempt to save power,
and thought this might be the reason.
To check, I turned off the timed screen blank.

> Settings > Privacy & Security > Blank Screen Delay > never

This fixed the problem.
I want to figure out how to get the system to go to sleep in order to save power,
but I set that aside for another time and got back to my original problem.

I re-triggered the graphics freeze and checked the Sunshine logs,
but didn't see anything suspicious.

I noticed that when the game's graphics were frozen, Steam's graphics were also mostly frozen.
I could open some drop-down menus, but I couldn't load a new page or interact with anything else.

After force-quitting the game, Steam continued to show a close game button.
When I clicked this button, Steam tried to boot the game again but no window popped up.
Even worse, Moonlight also disconnected and I wasn't able to reconnect.
Restarting Sunshine from its web UI did not resolve this issue.
As before, a reboot did.

I tried having the TV on while streaming with Sunshine set to use the dummy plug, but that didn't change anything.

At this point it seems like this problem either has something to do with Steam or the GPU and drivers.

I decided to go a 3rd route: see how things work without just the TV connected, no dummy plug.
It worked great!
The TV was recognized as a monitor and allowing for Sunshine/Moonshine streaming even when it was off.

The TV's 1080p resolution is the same I like using for streaming, so there's no mismatch to figure out.
If I ever get a new TV with a higher resolution,
I'll have to figure out how to still stream at 1080p.

I wish I knew what the problem was, but mostly I'm happy things are working.

