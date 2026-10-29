@echo off
REM ============================================================================
REM  Allow-XenoSwitch.bat
REM
REM  Double-click this to run Allow-XenoSwitch.ps1 correctly.
REM
REM  A .ps1 file opens in Notepad when double-clicked, and PowerShell's default
REM  policy can refuse to run it. This launcher runs the PowerShell helper the
REM  right way so you don't have to know the trick.
REM
REM  It does NOT do anything itself. All it does is start the .ps1 next to it,
REM  which will then SHOW you exactly what it will change and ASK before doing
REM  anything. See Allow-XenoSwitch.ps1 for the full explanation.
REM ============================================================================
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Allow-XenoSwitch.ps1"
