:: For development purposes

@echo off
cls
set /P id=Enter Loginserver Account Name to GM:
"bin/world.exe" database:set-account-status %id% 255

pause
