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

## Heads-up: Windows Defender may quarantine this

**Please read this before downloading.** Windows Defender currently flags this
app as `Trojan:Win32/Bearfoos.A!ml`. It is a false positive, but you deserve
the full story rather than a reassurance.

**Why it happens.** The app is Python packaged with PyInstaller. Defender's
machine-learning heuristic — the `!ml` suffix means a *guess*, not a match
against known malware — scores the PyInstaller startup stub highly, because
some real malware is built with the same freely available tool. Thousands of
legitimate Python apps hit this.

I verified the cause rather than assuming it: an alternative build whose
startup stub is only 2.4 MB and contains no bundled archive is flagged
identically. So the verdict is on the packaging tool, not on anything this app
does.

**What's being done about it.** The file has been submitted to Microsoft for
reclassification, which is the fix that works for everybody. Until a definition
update lands, the detection may come and go.

**What this app actually does:** reads and switches Windows audio endpoints
through the same COM interfaces the Sound control panel uses, installs a
keyboard hook for the hotkeys you configure, and writes one JSON settings file.
It makes **no network connections at all** and needs no administrator rights.
The complete source is linked below — read it.

### How to decide for yourself

Don't take my word for it:

1. **Check it on [VirusTotal](https://www.virustotal.com/).** Upload the exe, or
   search its SHA-256 (published on each release) to see what ~70 engines say.
   A handful of heuristic detections on a PyInstaller build is typical and
   expected; a broad consensus across major engines would not be, and would be
   a good reason not to run it.
2. **Verify the download is the file I published**, so you know it wasn't
   tampered with in transit:
   ```powershell
   Get-FileHash .\XenoSwitch.exe -Algorithm SHA256
   ```
   Compare the result against the hash on the release page.
3. **Read the source.** It's all public.

If after that you're not comfortable, **don't run it** — that's a completely
reasonable call, and I'd rather you skipped it than ran something you don't
trust.

If Defender quarantines it and you do want to keep it, Windows' own
Virus & threat protection UI has a "Restore" / "Allow on device" button for
exactly this. You should never have to disable your antivirus or paste
commands you don't understand to run a utility like this one.

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
