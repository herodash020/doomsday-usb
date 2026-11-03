# doomsday-usb

> **ALPHA v0.1** — experimental Windows USB-to-USB file copier.

Copy the visible contents of one USB drive to another without formatting or wiping the destination.

## What Alpha v0.1 does

- Lists removable drives and asks you to choose a **source** and a different **destination**.
- Copies files and folders from the source drive root, including hidden items where Windows permits access.
- Creates a new folder named `DOOMSDAY_USB_COPY` on the destination. If that folder already exists, it stops rather than overwriting it.
- Checks available destination space before copying.
- Uses Windows Robocopy and writes a log to the destination copy folder.

## Important limitations

This is a **file copy**, not a sector-by-sector disk clone. It does not copy partition tables, boot sectors, filesystem metadata, or guarantee that the destination is bootable. Windows-protected or in-use files may not be readable. Some system-managed folders (such as System Volume Information and $RECYCLE.BIN) are intentionally excluded.

The script does not format, repartition, erase, mirror, or purge the destination. It does not delete destination files. Alpha software can still contain bugs: keep your master USB unchanged and maintain another backup.

## Requirements

- Windows 10/11
- PowerShell 5.1 or later
- Two drives recognized by Windows as removable drives
- Destination has enough free space

## Run

1. Download this repository or clone it.
2. Open PowerShell in the project folder.
3. Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\Copy-Usb.ps1
```

The script asks you to select the source and destination by drive letter. Check the letters carefully before confirming.

## Project status

Alpha v0.1. Tested hardware and edge cases are not yet comprehensively validated. See [CHANGELOG.md](CHANGELOG.md).

## License

MIT. See [LICENSE](LICENSE).
