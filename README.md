# doomsday-usb

> **ALPHA v0.2** — experimental Windows USB-to-USB installer.

Doomsday USB copies the contents of a master USB to another USB without formatting or wiping the destination.

## Installer choices

- **Normal install:** copies all source files and folders.
- **Custom install:** copies all non-Wikipedia system files, then copies only the selected `.zim` offline knowledge archives. The installer discovers `.zim` files on the selected source USB.

The installer asks you to select the source and destination drives. It creates a new `DOOMSDAY_USB_COPY` folder on the destination. If that folder already exists, it stops instead of overwriting it.

## Download and run

Download `DoomsdayUSB-Installer.exe` from [GitHub Releases](https://github.com/herodash020/doomsday-usb/releases). Connect both USB drives, run the EXE, choose Normal or Custom, select any wikis, and confirm.

## Safety and limitations

- This is a **file-level copy**, not a sector-by-sector disk clone.
- It does not copy partition tables or boot sectors and does not make the destination bootable.
- It never formats, repartitions, mirrors, purges, or deletes destination data.
- It refuses to use an existing `DOOMSDAY_USB_COPY` folder.
- Windows-managed folders and some locked/protected files may be skipped.
- Custom mode excludes all discovered `.zim` files from the bulk copy, then copies only the checked archives.
- The current alpha writes a Robocopy log and a copy report, but does not perform a full cryptographic hash verification.

**Test with spare USB drives first. Keep your master USB unchanged and maintain another backup.**

## Requirements

- Windows 10/11
- Two drives recognized by Windows as removable USB drives
- Destination has enough free space

See [TESTING.md](TESTING.md) and [CHANGELOG.md](CHANGELOG.md).
