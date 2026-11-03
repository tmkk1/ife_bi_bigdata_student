@echo off
title BI and Big Data Analysis - Automated Windows Setup
echo ====================================================================
echo   BI and Big Data Analysis (01 31 0367 00) - Windows Setup Launcher
echo ====================================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup_windows.ps1"

echo.
pause

