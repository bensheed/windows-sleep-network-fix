@echo off
:: Windows Sleep Network Fix - Batch Installer
:: Automatically elevates to administrator and runs the PowerShell setup script

title Windows Sleep Network Fix - Setup

:: Check if already running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges...
    goto :run_setup
)

:: Not running as admin, attempt to elevate
echo.
echo ========================================
echo  Windows Sleep Network Fix - Setup
echo ========================================
echo.
echo This script needs administrator privileges to:
echo - Create network reconnection scripts
echo - Set up Windows scheduled tasks
echo - Configure system-level network fixes
echo.
echo Requesting administrator privileges...
echo.

:: Try to elevate using PowerShell
powershell -Command "Start-Process '%~f0' -Verb RunAs" 2>nul
if %errorLevel% == 0 (
    echo Elevation request sent. Please check for UAC prompt.
    timeout /t 3 >nul
    exit /b 0
) else (
    echo Failed to request elevation via PowerShell.
    echo.
    echo Please try one of these alternatives:
    echo 1. Right-click this file and select "Run as administrator"
    echo 2. Run from an administrator command prompt
    echo 3. Use the PowerShell script directly: SetupAutoReconnect.ps1
    echo.
    pause
    exit /b 1
)

:run_setup
echo.
echo ========================================
echo  Running Setup with Admin Privileges
echo ========================================
echo.

:: Check if PowerShell script exists
if not exist "%~dp0SetupAutoReconnect.ps1" (
    echo ERROR: SetupAutoReconnect.ps1 not found in the same directory!
    echo.
    echo Please ensure both files are in the same folder:
    echo - SetupAutoReconnect.bat
    echo - SetupAutoReconnect.ps1
    echo.
    pause
    exit /b 1
)

:: Run the PowerShell script with bypass execution policy
echo Running PowerShell setup script...
echo.
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0SetupAutoReconnect.ps1"

:: Check if PowerShell script ran successfully
if %errorLevel% == 0 (
    echo.
    echo ========================================
    echo  Setup completed successfully!
    echo ========================================
    echo.
    echo Your network will now automatically reconnect after sleep/wake cycles.
    echo.
    echo Files created in C:\NetworkReconnect\:
    echo - NetworkReconnect.ps1 ^(main script^)
    echo - RunManually.bat ^(for testing^)
    echo - log.txt ^(activity logs^)
    echo.
    echo Scheduled task "NetworkReconnectOnWake" has been created.
    echo.
) else (
    echo.
    echo ========================================
    echo  Setup encountered an error!
    echo ========================================
    echo.
    echo The PowerShell script returned error code: %errorLevel%
    echo.
    echo Common solutions:
    echo 1. Ensure you're running as Administrator
    echo 2. Check Windows PowerShell is available
    echo 3. Verify no antivirus is blocking the script
    echo.
    echo For manual setup, run: SetupAutoReconnect.ps1
    echo.
)

echo Press any key to exit...
pause >nul
exit /b %errorLevel%