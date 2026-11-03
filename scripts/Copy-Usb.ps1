# doomsday-usb Alpha v0.1
# Safe file-level USB copier. Never formats or deletes destination data.

$ErrorActionPreference = 'Stop'

function Get-RemovableDrives {
    Get-CimInstance Win32_LogicalDisk -Filter "DriveType = 2" |
        Where-Object { $_.DeviceID -match '^[A-Z]:$' } |
        Sort-Object DeviceID
}

function Format-Drive($drive) {
    $label = if ($drive.VolumeName) { $drive.VolumeName } else { 'No label' }
    $free = [math]::Round($drive.FreeSpace / 1GB, 2)
    $size = [math]::Round($drive.Size / 1GB, 2)
    "{0}\  {1}  ({2} GB free / {3} GB)" -f $drive.DeviceID, $label, $free, $size
}

Write-Host ""
Write-Host "DOOMSDAY-USB — ALPHA v0.1" -ForegroundColor Cyan
Write-Host "File copy only. No formatting, wiping, or deletion."
Write-Host ""

$drives = @(Get-RemovableDrives)
if ($drives.Count -lt 2) {
    throw "Connect both USB drives. Windows currently detects $($drives.Count) removable drive(s)."
}

Write-Host "Detected removable drives:"
for ($i = 0; $i -lt $drives.Count; $i++) {
    Write-Host ("[{0}] {1}" -f ($i + 1), (Format-Drive $drives[$i]))
}

$sourceChoice = Read-Host "Select MASTER/source drive number"
if ($sourceChoice -notmatch '^\d+$' -or [int]$sourceChoice -lt 1 -or [int]$sourceChoice -gt $drives.Count) {
    throw "Invalid source selection."
}
$source = $drives[[int]$sourceChoice - 1]

$destinationOptions = @()
for ($i = 0; $i -lt $drives.Count; $i++) {
    if ($drives[$i].DeviceID -ne $source.DeviceID) { $destinationOptions += $drives[$i] }
}
Write-Host ""
Write-Host "Choose destination:"
for ($i = 0; $i -lt $destinationOptions.Count; $i++) {
    Write-Host ("[{0}] {1}" -f ($i + 1), (Format-Drive $destinationOptions[$i]))
}

$destinationChoice = Read-Host "Select DESTINATION drive number"
if ($destinationChoice -notmatch '^\d+$' -or [int]$destinationChoice -lt 1 -or [int]$destinationChoice -gt $destinationOptions.Count) {
    throw "Invalid destination selection."
}
$destination = $destinationOptions[[int]$destinationChoice - 1]

$sourceRoot = "$($source.DeviceID)\"
$destinationRoot = "$($destination.DeviceID)\"
$targetFolder = Join-Path $destinationRoot "DOOMSDAY_USB_COPY"

if ($source.DeviceID -eq $destination.DeviceID) { throw "Source and destination must be different drives." }
if (Test-Path -LiteralPath $targetFolder) {
    throw "Destination folder already exists: $targetFolder. Rename or move it yourself; this script will not overwrite it."
}

Write-Host ""
Write-Host "SOURCE:      $sourceRoot" -ForegroundColor Yellow
Write-Host "DESTINATION: $targetFolder" -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "Type COPY to begin"
if ($confirm -cne "COPY") { Write-Host "Cancelled. Nothing was copied."; exit 0 }

# Estimate source size. Exclude Windows-managed folders and reparse points.
Write-Host "Calculating source size. This may take a while..."
$excludedNames = @('System Volume Information', '$RECYCLE.BIN')
$totalBytes = [int64]0
$scanErrors = @()
Get-ChildItem -LiteralPath $sourceRoot -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notin $excludedNames -and -not ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) } |
    ForEach-Object {
        if ($_.PSIsContainer) {
            Get-ChildItem -LiteralPath $_.FullName -Force -File -Recurse -ErrorAction SilentlyContinue |
                Where-Object { -not ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) } |
                ForEach-Object { $totalBytes += $_.Length }
        } else {
            $totalBytes += $_.Length
        }
    }

$destinationInfo = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID = '$($destination.DeviceID)'"
if ($destinationInfo.FreeSpace -lt $totalBytes) {
    throw ("Not enough space. Estimated source size: {0:N2} GB; destination free: {1:N2} GB." -f ($totalBytes / 1GB), ($destinationInfo.FreeSpace / 1GB))
}

New-Item -ItemType Directory -Path $targetFolder | Out-Null
$logPath = Join-Path $targetFolder "doomsday-usb-copy.log"
$robocopyArgs = @(
    $sourceRoot,
    $targetFolder,
    '/E',
    '/COPY:DAT',
    '/DCOPY:DAT',
    '/R:2',
    '/W:2',
    '/XJ',
    '/FFT',
    '/NP',
    '/TEE',
    '/LOG:' + $logPath,
    '/XD',
    (Join-Path $sourceRoot 'System Volume Information'),
    (Join-Path $sourceRoot '$RECYCLE.BIN')
)

Write-Host ""
Write-Host "Copying files. Large USB drives may take a long time..." -ForegroundColor Cyan
& robocopy @robocopyArgs
$copyCode = $LASTEXITCODE

if ($copyCode -ge 8) {
    Write-Warning "Robocopy reported a failure (exit code $copyCode). Review the log: $logPath"
    Write-Host "The partial copy has been left in place. Nothing on the destination was deleted."
    exit $copyCode
}

$reportPath = Join-Path $targetFolder "COPY-REPORT.txt"
@"
DOOMSDAY-USB ALPHA v0.1
Started: $(Get-Date)
Source: $sourceRoot
Destination: $targetFolder
Robocopy exit code: $copyCode
Result: Robocopy completed without a fatal error.
Note: This is a file-level copy, not a bootable disk clone. Check the log for skipped or inaccessible files.
"@ | Set-Content -LiteralPath $reportPath -Encoding UTF8

Write-Host ""
Write-Host "Copy completed. Robocopy exit code: $copyCode" -ForegroundColor Green
Write-Host "Log:    $logPath"
Write-Host "Report: $reportPath"
Write-Host "Review the log for skipped files before relying on this copy."
