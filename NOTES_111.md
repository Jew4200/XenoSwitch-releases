## XenoSwitch 1.1.1

**Fixes the antivirus problem.** If v1.1.0 was deleted by Windows Defender as
soon as you downloaded it, this release should not be.

### What changed

Defender's cloud heuristic was flagging the **stock PyInstaller startup stub**
as `Trojan:Win32/Bearfoos.A!ml`. That stub is byte-identical in every app built
with PyInstaller, so it matches malware packaged with the same freely available
tool — nothing to do with what XenoSwitch actually does.

This release is built with a startup stub **compiled from source** instead of
the prebuilt one. Different bytes, no match.

How that was confirmed rather than guessed:

- An alternative build with a 2.4 MB stub and no bundled archive was flagged
  *identically*, which pointed at the stub rather than the packaging.
- Splitting the old exe showed neither half flagged on its own.
- An on-demand scan passed while the real-time path had deleted the same file
  minutes earlier — so the verdict was cloud-delivered and tied to the file
  hash.
- Self-signing alone did **not** stop the deletions.

The rebuilt binary was then tested in every place the old one died: an explicit
scan, a copy into Downloads, a copy onto the Desktop, and being run. It
survived all four, with zero detections.

### Honest caveats

- Antivirus heuristics change. If a future definition update flags this build
  too, please open an issue — the fix is repeatable.
- A false-positive report for the previous build has been submitted to
  Microsoft, which clears it for everyone once processed.
- The app is signed, but with a self-signed certificate, so Windows will not
  show it as a verified publisher. Verify the SHA-256 below if you want
  certainty that your download is intact.

### No functional changes

Identical to 1.1.0 in behaviour. All 15 test suites pass, including the three
that drive the packaged binary.

### Verify your download

```
SHA256  1891ba8f4576dd59db0af2f4000d1d7120bc8241bcc1a8fb9ddf2fa34a8f27df
```

```powershell
Get-FileHash .\XenoSwitch.exe -Algorithm SHA256
```

A `XenoSwitch.exe.sha256` file is attached for automated checking.

### Requirements

Windows 10 or 11, 64-bit. No installer, no admin rights, nothing to install.
