# Alpha v0.2 testing checklist

Use two spare USB drives or disposable test data. Do not test with your only copy of important files.

- [ ] Confirm both removable drives appear in the source and destination lists.
- [ ] Confirm the same drive cannot be selected as both source and destination.
- [ ] Normal mode copies all ordinary files, folders, and hidden files.
- [ ] Custom mode lists discovered .zim files.
- [ ] Custom mode copies non-wiki files plus only the checked .zim files.
- [ ] Custom mode with no selected archives asks you to select at least one.
- [ ] An existing DOOMSDAY_USB_COPY folder causes a safe stop.
- [ ] Cancelling the confirmation prompt makes no changes.
- [ ] Review the Robocopy log and COPY-REPORT.txt.
- [ ] Check the destination on a second Windows PC.

## Known limitations

This is a file-level copy, not a sector clone. It does not reproduce partitions or boot sectors. Windows-managed folders and locked/protected files may not copy. Alpha v0.2 does not yet perform SHA-256 verification or a reliable full free-space preflight.
