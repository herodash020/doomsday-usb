# Changelog

## Alpha v0.2

- Added a Windows GUI installer.
- Added Normal install to copy the entire source USB.
- Added Custom install to choose which discovered .zim archives are copied while retaining non-wiki system files.
- Added source and destination drive selection and a confirmation prompt.
- Retained non-destructive destination behavior and copy logs.
- Updated GitHub Actions to build and publish a standalone GUI EXE on a version tag.

## Alpha v0.1

- Initial Windows PowerShell USB file-copy prototype.
- Select removable source and destination drives.
- Copy into a new destination folder without deleting existing destination data.
- Check estimated free space and retain a Robocopy log.
- Explicitly exclude Windows-managed System Volume Information and $RECYCLE.BIN folders.
