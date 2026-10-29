## XenoSwitch 1.1.0

First public release. One file, no installer, no admin rights required.

### What it does

- Switch a whole group of playback/recording endpoints with one toggle
- Mark any device as **default** while the profile is engaged — all three roles
  (console, multimedia and communications), so Discord and Teams follow too —
  and have the previous defaults restored exactly when you switch back
- Global hotkeys, including **multi-key combos like F8+F9** that the standard
  Windows hotkey API cannot express
- Per-device volume sliders with mute
- Lives in the tray; hotkeys keep working with the window closed

### Fixed in this release

- **Memory leak (critical).** The image cache was unbounded and keyed partly on
  a widget's live pixel width, so dragging the window edge through 300 widths
  held 300 supersampled images forever. Measured **+418 MB RSS from a single
  resize drag**, never returned — bad for an app that idles in the tray for
  days. Now a bounded LRU; the same abusive sweep settles at +9.3 MB.
- **Stuck hotkey key (critical).** If a key-up was lost — a UAC prompt, Win+L
  or an RDP switch taking the input desktop mid-combo — that key stayed "held"
  forever. Afterwards, pressing just one half of the combo would switch your
  audio *and* swallow the key from whatever app you were using. Held keys now
  expire automatically.
- **64-bit handle truncation** in the DPI lookup — the same class of bug that
  previously broke the hotkey and tray threads in the packaged build. An HDC
  leak on the error path went with it.
- Removed a dead guard in the profile-switch planner that made the snapshot
  protection look stronger than it actually was.

The test suite — 12 suites covering the COM layer, the UI, race conditions and
the packaged binary — passes fully for the first time.

### Verify your download

```
SHA256  5c6520574283a9d48897ea5ed776cfa9d5c59e81736ae05121acdfc75fea2105
```

```powershell
Get-FileHash .\XenoSwitch.exe -Algorithm SHA256
```

A `XenoSwitch.exe.sha256` file is attached for automated checking.

### Windows Defender may quarantine this — please read

Defender currently flags this build as `Trojan:Win32/Bearfoos.A!ml`. It is a
false positive on the **PyInstaller packaging tool**, not on anything this app
does. The `!ml` suffix means a machine-learning guess rather than a match
against known malware.

I confirmed the cause rather than assuming it: an alternative build whose
startup stub is only 2.4 MB with no bundled archive is flagged identically, so
the verdict is on the packaging stub itself.

This file has been submitted to Microsoft for reclassification, which is the
fix that works for everyone. Until a definition update lands, the detection may
come and go.

**Decide for yourself before running it:** check the SHA-256 above matches your
download, look the hash up on [VirusTotal](https://www.virustotal.com/), and
read the source. If you're not comfortable after that, don't run it.

You should **not** need to disable your antivirus or paste commands to use this
app. If Defender quarantines it and you want to keep it, Windows' own Virus &
threat protection screen has a Restore / Allow button for exactly this.

### Requirements

Windows 10 or 11, 64-bit. Nothing to install.
