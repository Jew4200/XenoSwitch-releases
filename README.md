# XenoSwitch

Flip a whole set of Windows audio endpoints on and off with one switch — or one
hotkey — and have the default playback device move with them and come back
afterwards.

Built for loopback rigs: enable *Speakers* + *Stereo Mix* together, make the
speakers the default while they're on, then put everything back exactly as it
was when you flip the switch off.

**[Download the latest release →](../../releases/latest)**

One file. No installer, no Python, no admin rights.

---

## What it does

- **Switch a group of endpoints together.** Put any mix of playback and
  recording devices in a profile; one toggle enables or disables all of them.
- **Keep audio where you want it.** Mark any device in the profile with
  `☆ SET DEFAULT`. While the profile is engaged that endpoint takes over as the
  default for all three roles — console, multimedia *and* communications — so
  apps that follow the default (Discord and Teams use the communications role)
  move with it. Releasing puts the previous defaults back exactly.
- **Global hotkeys, including combos Windows can't normally express.** Classic
  `Ctrl`/`Alt`/`Shift`/`Win` combinations, or **any two or more keys held
  together** — `F8+F9`, `F7+F8+F9` — which are essentially impossible to press
  by accident. None are set by default.
- **Per-device volume sliders** with mute, reading the endpoint's real master
  volume so they stay in step with the Windows mixer.
- **Lives in the tray.** Closing hides it; hotkeys keep working.

## Colour language

| Colour | Meaning |
| --- | --- |
| **Mint** | enabled / active |
| **Magenta** | disabled |
| **Amber** | enabled but nothing plugged into the jack |
| **Grey** | not connected |

## Requirements

Windows 10 or 11, 64-bit. Nothing else — no runtime to install, and it does
**not** need administrator rights.

## Your antivirus may flag it

Windows Defender's machine-learning heuristic flags unsigned one-file
PyInstaller executables fairly often, usually as `Trojan:Win32/Bearfoos.A!ml`.
The `!ml` suffix means a heuristic guess, not a signature match for known
malware. This is a well-known false positive for this kind of build, and it has
hit this app on the developer's own machine.

The releases are Authenticode-signed, but with a self-signed certificate — that
removes one of the signals the heuristic scores on, and it lets you confirm the
binary hasn't been tampered with, but it isn't a certificate from a public
authority and Windows won't treat it as trusted.

If Defender quarantines it and you want to keep it, add an exclusion for the
folder you keep it in:

```powershell
Add-MpPreference -ExclusionPath "C:\path\to\your\XenoSwitch\folder"
```

Run that in an **administrator** PowerShell. Only do this if you trust the
download — verify the SHA-256 against the one published on the release first.

## How it works

Enable/disable goes through `IPolicyConfig::SetEndpointVisibility`, the same
undocumented COM call the Sound control panel uses for its own Enable/Disable
menu items. It talks to `audiosrv`, so changes apply immediately — no service
restart, no reboot, no elevation.

Multi-key combos use a `WH_KEYBOARD_LL` low-level keyboard hook, because
`RegisterHotKey` has modifier bits only for Ctrl/Alt/Shift/Win and literally
cannot express "F8+F9".

## Known limitation

An app that opened one *specific* endpoint at launch, or grabbed it in WASAPI
exclusive mode, is pinned to that device. Nothing outside that app can migrate
it — not XenoSwitch, not the Sound control panel. Restart such an app after
switching, or leave the endpoint it holds enabled and move the default around
it. Setting a default device handles everything that follows the system default.

Combo hotkeys also won't fire while a window running **as administrator** has
focus; Windows blocks lower-privilege keyboard hooks. Classic `RegisterHotKey`
bindings have the same restriction.

## Licence

MIT — see [LICENSE](LICENSE).
