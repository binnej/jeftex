@echo off
title JeFTeX uninstaller
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-JeFTeX.ps1" -Uninstall
echo.
pause
