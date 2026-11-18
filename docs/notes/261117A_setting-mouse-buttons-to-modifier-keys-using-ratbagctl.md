# Setting mouse buttons to modifier keys using ratbagctl

Start by getting device name.

```sh
ratbagctl list
```
```
singing-hare:        Logitech G502 X LIGHTSPEED
```

So device name is `singing-hare`.

```sh
ratbagctl singing-hare profile active set 0
ratbagctl singing-hare rate set 500
ratbagctl singing-hare resolution default set 2
ratbagctl singing-hare resolution active set 2
ratbagctl singing-hare dpi set 1600
ratbagctl singing-hare button 0 action set button 1
ratbagctl singing-hare button 1 action set button 2 
ratbagctl singing-hare button 2 action set button 3
ratbagctl singing-hare button 3 action set macro +KEY_LEFTALT KEY_F20 -KEY_LEFTALT
ratbagctl singing-hare button 4 action set macro +KEY_LEFTSHIFT KEY_F20 -KEY_LEFTSHIFT
ratbagctl singing-hare button 5 action set macro +KEY_LEFTCTRL KEY_F20 -KEY_LEFTCTRL
ratbagctl singing-hare button 6 action set special wheel-left
ratbagctl singing-hare button 7 action set special wheel-right
ratbagctl singing-hare button 8 action set disabled
ratbagctl singing-hare button 9 action set disabled
ratbagctl singing-hare button 10 action set disabled
```

I periodically read out the configuration to see where I'm at.

```
ratbagctl singing-hare info
```

`ratbagctl` will apply the changes to the mouse after each command.
I make sure the configuration is not flagged as _dirty_,
which means the configuration was not able to be applied to the mouse.

I remapped a few of the mouse's side buttons to the ctrl, shift, and alt modifier keys using a macro.
I had to insert a press of the F20 key between the modifier press and release because ratbagd can't handle the modifier alone.
It doesn't have to be F20, it could be any key, it's just that F20 is an effective no-op since it's not on a normal keyboard.

https://github.com/libratbag/libratbag/issues/1205
