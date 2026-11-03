@echo off
title DOOMSDAY-USB ALPHA v0.1
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Copy-Usb.ps1"
if errorlevel 1 (
  echo.
  echo The copy process reported an error. Review the message above.
)
echo.
pause
