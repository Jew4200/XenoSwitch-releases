## XenoSwitch 1.1.2

**Fixes buttons going missing after you minimise the window or reopen it from
the tray.**

### What was wrong

The window looked fine when it first opened. After some use (toggling
devices, moving volume sliders), minimising it or reopening it from the tray
could bring it back with switches, sliders or buttons blank. The only fix was
to close it and launch it again.

Every switch, slider and button is a small drawn image. The app keeps a
limited number of those in memory and throws the oldest away. The bug was that
an image could be thrown away while it was still on screen. Windows kept
showing the old picture until it redrew the window, and redrawing is exactly
what minimising or reopening does, so that's when they went blank.

### The fix

Each control now holds on to the image it is currently showing, so throwing
old images away can no longer remove one that is on screen. Memory use stays
bounded.

### How it was checked

- A test that runs the real app and pushes it past that image limit found
  58 of 60 on-screen images deleted before the fix, and none after.
- The profile, edge-case and volume-slider UI test suites pass.
- The packaged exe was minimised and restored repeatedly and redrew fully
  every time.

No other changes in behaviour. Built the same way as 1.1.1, using the startup
stub compiled from source rather than the one Defender flags.

### Verify your download

```
SHA256  545f3e984010d92dca94d9993a379d1014766bb64a6653c6d8af6d99764d3b95
```

```powershell
Get-FileHash .\XenoSwitch.exe -Algorithm SHA256
```

A `XenoSwitch.exe.sha256` file is attached for automated checking.

### Requirements

Windows 10 or 11, 64-bit. No installer, no admin rights, nothing to install.
