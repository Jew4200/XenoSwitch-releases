# ============================================================================
#  Allow-XenoSwitch.ps1
#
#  WHAT THIS IS
#  ------------
#  Windows Defender's machine-learning heuristic wrongly flags XenoSwitch as
#  "Trojan:Win32/Bearfoos.A!ml". It is a false positive: the trigger is the
#  PyInstaller tool the app is packaged with, which thousands of legitimate
#  Python apps also use. XenoSwitch makes no network connections, needs no
#  administrator rights to run, and its full source is public:
#      https://github.com/Jew4200/XenoSwitch-releases
#
#  WHAT THIS SCRIPT DOES
#  ---------------------
#  It adds ONE Windows Defender exclusion, for the single folder this script
#  lives in, so Defender stops deleting XenoSwitch.exe. That is all. It:
#    * does NOT disable your antivirus
#    * does NOT turn off real-time protection
#    * does NOT exclude anything except this one folder
#    * does NOT touch any other setting, file, or program
#
#  It will SHOW you the exact command and ASK before changing anything. If you
#  say no, it changes nothing.
#
#  WHY A FOLDER EXCLUSION IS THE RIGHT SCOPE
#  -----------------------------------------
#  Excluding just this folder means every other file on your PC stays fully
#  protected. Only files you deliberately put in this folder are skipped, so
#  keep this folder for XenoSwitch and nothing else.
#
#  ONLY RUN THIS IF YOU TRUST THE DOWNLOAD. Verify the SHA-256 of
#  XenoSwitch.exe against the value on the release page first (this script
#  prints it for you below).
#
#  TO UNDO IT LATER (removes the exclusion):
#      Run an ADMINISTRATOR PowerShell and paste:
#
#      Remove-MpPreference -ExclusionPath "<this folder's full path>"
#
#  The script prints the exact revert command for your machine when it runs.
# ============================================================================

$ErrorActionPreference = 'Stop'
$Folder = Split-Path -Parent $MyInvocation.MyCommand.Path
$Exe    = Join-Path $Folder 'XenoSwitch.exe'

function Pause-Exit([int]$code) {
    Write-Host ''
    Write-Host 'Press Enter to close...' -ForegroundColor DarkGray
    [void](Read-Host)
    exit $code
}

Write-Host ''
Write-Host '  XenoSwitch - allow through Windows Defender' -ForegroundColor Cyan
Write-Host '  ===========================================' -ForegroundColor Cyan
Write-Host ''
Write-Host "  This folder: $Folder"
Write-Host ''

# --- Show the hash so the user can verify the download before allowing it ----
if (Test-Path $Exe) {
    try {
        $hash = (Get-FileHash $Exe -Algorithm SHA256).Hash
        Write-Host '  XenoSwitch.exe SHA-256 (compare this to the release page):'
        Write-Host "    $hash" -ForegroundColor Yellow
    } catch {
        Write-Host '  (Could not read XenoSwitch.exe to hash it - Defender may' -ForegroundColor DarkYellow
        Write-Host '   have already quarantined it. That is expected; continue.)' -ForegroundColor DarkYellow
    }
} else {
    Write-Host '  NOTE: XenoSwitch.exe is not in this folder yet. If Defender' -ForegroundColor DarkYellow
    Write-Host '  already deleted it, add the exclusion first, then re-download.' -ForegroundColor DarkYellow
}
Write-Host ''

# --- Must be elevated to change Defender settings ----------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host '  This needs to run as Administrator (changing a Defender' -ForegroundColor Yellow
    Write-Host '  setting requires it). Re-launching with an elevated prompt...' -ForegroundColor Yellow
    Write-Host '  You will see a User Account Control (UAC) dialog - that is' -ForegroundColor Yellow
    Write-Host '  Windows asking your permission, which is correct.' -ForegroundColor Yellow
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList @(
            '-NoProfile','-ExecutionPolicy','Bypass',
            '-File', "`"$($MyInvocation.MyCommand.Path)`""
        )
    } catch {
        Write-Host ''
        Write-Host '  You declined the elevation prompt. Nothing was changed.' -ForegroundColor Red
    }
    exit
}

# --- The exact command, shown before it runs ---------------------------------
Write-Host '  The exact command that will run:' -ForegroundColor Cyan
Write-Host ''
Write-Host "    Add-MpPreference -ExclusionPath `"$Folder`"" -ForegroundColor White
Write-Host ''
Write-Host '  To undo this later, run in an Administrator PowerShell:' -ForegroundColor Cyan
Write-Host ''
Write-Host "    Remove-MpPreference -ExclusionPath `"$Folder`"" -ForegroundColor White
Write-Host ''

# --- Already excluded? -------------------------------------------------------
try {
    $existing = (Get-MpPreference).ExclusionPath
    if ($existing -and ($existing -contains $Folder)) {
        Write-Host '  This folder is ALREADY excluded. Nothing to do.' -ForegroundColor Green
        Pause-Exit 0
    }
} catch {
    Write-Host '  (Could not read current exclusions - continuing.)' -ForegroundColor DarkYellow
}

# --- Consent gate ------------------------------------------------------------
$answer = Read-Host '  Add this exclusion now? Type  yes  to proceed'
if ($answer -ne 'yes') {
    Write-Host ''
    Write-Host '  No changes made.' -ForegroundColor Green
    Pause-Exit 0
}

# --- Do it -------------------------------------------------------------------
try {
    Add-MpPreference -ExclusionPath $Folder
    Write-Host ''
    Write-Host '  Done. This folder is now excluded from Windows Defender' -ForegroundColor Green
    Write-Host '  scanning. XenoSwitch.exe will no longer be deleted.' -ForegroundColor Green
    Write-Host ''
    Write-Host '  Keep this folder for XenoSwitch only. To undo, run the' -ForegroundColor Gray
    Write-Host '  Remove-MpPreference command shown above in an admin prompt.' -ForegroundColor Gray

    # If Defender already quarantined the exe, offer to restore it.
    if (-not (Test-Path $Exe)) {
        Write-Host ''
        Write-Host '  XenoSwitch.exe is not present - Defender likely quarantined' -ForegroundColor Yellow
        Write-Host '  it earlier. Re-download it from the release page; it will' -ForegroundColor Yellow
        Write-Host '  now be allowed to stay. (Or restore it from Windows' -ForegroundColor Yellow
        Write-Host '  Security > Protection history.)' -ForegroundColor Yellow
    }
} catch {
    Write-Host ''
    Write-Host "  Failed to add the exclusion: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host '  You can do it manually in Windows Security > Virus & threat' -ForegroundColor Red
    Write-Host '  protection > Manage settings > Exclusions > Add folder.' -ForegroundColor Red
}

Pause-Exit 0
