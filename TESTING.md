# Alpha v0.1 testing checklist

Do not test first on the only copy of important data. Use two spare USB drives or test with disposable files.

- [ ] Confirm both USB drives appear in the drive list.
- [ ] Confirm selecting the same drive as source and destination is impossible.
- [ ] Confirm cancelling at the `Type COPY` prompt makes no changes.
- [ ] Confirm an existing `DOOMSDAY_USB_COPY` folder causes the script to stop without changing it.
- [ ] Confirm a destination with insufficient free space is rejected.
- [ ] Copy a test source containing normal files, nested folders, and hidden files.
- [ ] Compare source and destination contents manually.
- [ ] Review `doomsday-usb-copy.log` and `COPY-REPORT.txt` for skipped or failed files.
- [ ] Test with a safely removable USB drive and inspect the result on another PC.

## Known Alpha limitations

This is a file-level copy, not a sector clone. It does not reproduce partitions, boot sectors, or make a USB bootable. Windows-managed folders are excluded, and locked or protected files may not copy. The current script records a Robocopy log but does not perform a cryptographic hash comparison.
